import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dcli/dcli.dart' as cli;
import 'package:mailjet_sender/mailjet_sender.dart';

import '../../../backup.dart';
import '../../storage/storage_adapter.dart';
import '../../utils.dart';

class MakeBackup extends Command<dynamic> {
  static const _backupDir = 'backup/';
  static const String tag = ' :: MakeBackup :: ';

  MakeBackup() {
    argParser
      ..addOption('name',
          help: 'Name from server to identify backup file itself');
  }

  late String _name;
  bool _mailServiceAvailable = false;
  late Store? _store;

  @override
  String get description => 'Make a backup';

  @override
  String get name => 'make';

  // FORMAT: servername_01-02-1992_backup/
  String get backupDir => '${_name.trim()}_${getTodayAsString}_${_backupDir}';

  // FORMAT: 01-02-2020
  String get getTodayAsString {
    final today = DateTime.now();
    return '${today.day}-${today.month}-${today.year}';
  }

  @override
  Future<void> run() async {
    _parseInput();

    // retrieve secured local storage
    _store = await StorageAdapter.get();

    // all backup data created during current session
    //  will be saved in this directory
    FileUtils.createDirectory(backupDir);

    // enable email notifier when data was provided
    _enableEmailServiceIfProvided();

    // check for availability of secured local storage
    if (_store == null) {
      _stopAndMakeErrorReport(
          'STORAGE NOT FOUND! Could not found local storage. Mostly wrong key!');
    }

    // make backups
    late String serverLogs;
    if ((_store!.postgresName.isNotEmpty) && _store!.postgresDataProvided) {
      makePostgresBackup();
    }
    if (_store!.serverImagePath.isNotEmpty) {
      serverLogs = makeServerBackup();
    }

    // compress backup data to a .zip file
    final pathToCompressedFile = FileUtils.compressDirectory(backupDir);
    if (pathToCompressedFile == null) {
      _stopAndMakeErrorReport('ERROR! Could not compress backup directory');
    }

    // send backup zip file with restic to a restic server
    makeResticCall(pathToCompressedFile!);

    // Todo make healthcare call with success and logs from server
    makeHealthCareCall(serverLogs);

    // removes all files which where created during current backup session
    FileUtils.removeDirectory(backupDir);

    exit(0);
  }

  /// Makes postgres backup in two steps
  ///   1. pg_dump call on database docker container to a tmp file into docker container
  ///   2. copy before created dump to [backupDir]
  void makePostgresBackup() {
    _checkForRunningContainer(_store!.postgresName);

    try {
      print('postgres exec command');
      'docker exec ${_store!.postgresName} pg_dumpall -c -U ${_store!.postgresDbUser} -f /tmp/dump.sql' // pg_dump -a -U ${_store!.postgresDbUser} --password ${_store!.postgresDbPw} -f /tmp/dump.sql'
          .start(runInShell: true);

      print('postgres copy command');
      'docker cp ${_store!.postgresName}:/tmp/dump.sql ${'pwd'.firstLine}/$backupDir'
          .start(runInShell: true);
    } catch (e) {
      _stopAndMakeErrorReport(
          'ERRROR! Could not make postgres backup \n Error: $e');
    }
  }

  // copy images from directory to backup directory
  String makeServerBackup() {
    'cp -r ${_store!.serverImagePath} ${'pwd'.firstLine}/$backupDir'.forEach(
        (line) {
      //print('$tag Docker cp of ${_store!.serverImagePath} \n $line');
    }, stderr: _stopAndMakeErrorReport, runInShell: true);

    // get last 10kb logs from server and return that data

    final tailCommand =
        Platform.isMacOS ? 'tail -b 10000' : 'tail --byte=10000';
    try {
      final logsList =
          ('docker logs ${_store!.serverContainerName}' | tailCommand).toList();
      return StringBuffer(logsList).toString();
    } catch (e) {
      _stopAndMakeErrorReport(
          'ERROR! Could not get logs from server \n Error: $e');
    }
    return '';
  }

  //
  //   restic encrypts backup data
  //   and sends the encrypted backup itself
  //   to a configured restic http server which exist
  //   in local network
  //
  //   restic is configured properly and
  //   is able to reach the restic server is
  //   an assumption to work here properly
  //
  // see restic:
  //   https://restic.readthedocs.io/en/latest/100_references.html#rest-backend
  //   https://github.com/restic/rest-server
  //
  // todo start restic client with compressed file and diagnostic output
  void makeResticCall(String pathToCompressedFile) {
    cli.env.addAll(<String, String>{'RESTIC_PASSWORD': _store!.resticPassword});
    'restic -r rest:${_store!.resticServerPath} --no-cache backup $pathToCompressedFile'
        .forEach((line) {
      print('$tag makeResticCall: $line');
    }, stderr: _stopAndMakeErrorReport);
  }

  void makeHealthCareCall(String logs) {
    'curl -fsS -m 10 --retry 5 --data-raw "$logs" "https://${_store!.healthCarePath}"'
        .forEach((line) {
      print('$tag makeHealthCareCall: $line');
    }, stderr: _stopAndMakeErrorReport);
  }

  void _parseInput() {
    _name = argResults?['name']?.toString() ?? '';

    if (!_validInputData) {
      print(cli.red('WRONG PARAMETER! Key and name must be provided!'));
      exit(1);
    }
  }

  bool get _validInputData => !_name.isEmpty;

  void _enableEmailServiceIfProvided() {
    if (_store != null && _store!.mailDataProvided) {
      EmailService.instance().setUp(_store!.mailJetPrivate,
          _store!.mailJetPublic, _store!.emailFrom, _store!.emailFrom);
      _mailServiceAvailable = true;
    }
  }

  // check if container runs currently
  //    stops and makes error report when container is not running
  void _checkForRunningContainer(String containerName) {
    if (!DockerUtils.isContainerReachable(containerName)) {
      _stopAndMakeErrorReport('CONTAINER $containerName NOT RUNNING!');
    }
  }

  // sends email and exits afterwards with 1
  void _stopAndMakeErrorReport(String error) {
    print(cli.red('$tag $_name ERROR: \n $error'));

    if (_mailServiceAvailable) {
      EmailService.instance().sendErrorReportEmail(
          '$tag $_name', 'ERROR: \n $error',
          mailToReportTo: _store!.emailTo);
    }

    'curl -fsS -m 10 --retry 5 --data-raw "$error" "https://${_store!.healthCarePath}/fail"'
        .forEach((line) {
      print('$tag makeHealthCareFailCall: $line');
    }, stderr: _stopAndMakeErrorReport);

    // no data lack should occur when program stops here
    // so first delete created directory and then exit
    FileUtils.removeDirectory(backupDir);
    exit(1);
  }
}
