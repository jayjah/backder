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

  String _name;
  bool _mailServiceAvailable = false;
  Store _store;

  @override
  String get description => 'Make a backup';

  @override
  String get name => 'make';

  // FORMAT: servername_01-02-1992_backup/
  String get backupDir =>
      '${_name?.trim() ?? ''}_${getTodayAsString}_${_backupDir}';

  // FORMAT: 01-02-2020
  String get getTodayAsString {
    final today = DateTime.now();
    return '${today.day}-${today.month}-${today.year}';
  }

  @override
  Future<void> run() async {
    _parseInput();

    // retrieve secured local storage by given key
    _store = await StorageAdapter.get();

    // all data from containers will be saved in this directory during
    //    current backup session
    FileUtils.createDirectory(backupDir);

    // enable email notifier when data was provided
    _enableEmailServiceIfProvided();

    // check for availability of secured local storage
    if (_store == null) {
      _stopAndMakeErrorReport(
          'STORAGE NOT FOUND! Could not found local storage. Mostly wrong key!');
    }

    // make backups
    if (_store.postgresName.isNotEmpty) {
      makePostgresBackup();
    }
    if (_store.serverName.isNotEmpty) {
      makeServerBackup();
    }

    // compress files to a .zip file
    final pathToCompressedFile = FileUtils.compressDirectory(backupDir);

    // send backup zip file with restic cli to a restic server
    makeResticCall(pathToCompressedFile);

    // removes all files which where created during current backup session
    FileUtils.removeDirectory(backupDir);

    return;
  }

  void makePostgresBackup() {
    _checkForRunningContainer(_store.postgresName);
    print('postgres exec command');
    'docker exec -i ${_store.postgresName} pg_dump -a --username ${_store.postgresDbName} --password ${_store.postgresDbPw} ${_store.postgresDbName} > /app/dump.sql'
        .run;

    print('postgres copy command');
    'docker cp ${_store.postgresName}:/app/dump.sql ${'pwd'.firstLine}/$backupDir'
        .run;
  }

  // copy images from docker container to backup directory
  void makeServerBackup() {
    _checkForRunningContainer(_store.serverName);

    'docker cp ${_store.serverName}:/app/public/images ${'pwd'.firstLine}/$backupDir'
        .forEach((line) {
      print('$tag Docker cp of ${_store.serverName} \n $line');
    }, stderr: _stopAndMakeErrorReport, runInShell: true);
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
  void makeResticCall(String pathToCompressedFile) {
    'restic'.forEach((line) {
      print('$tag restic command \n $line');
    }, stderr: _stopAndMakeErrorReport, runInShell: true);
    // todo start restic client with compressed file and diagnostic output
  }

  void _parseInput() {
    _name = argResults['name']?.toString();

    if (!_validInputData) {
      print(cli.red('WRONG PARAMETER! Key and name must be provided!'));
      return exit(1);
    }
  }

  bool get _validInputData => _name != null && !_name.isEmpty;

  void _enableEmailServiceIfProvided() {
    if (_store != null && _store.mailDataProvided) {
      EmailService.instance().setUp(_store.mailJetPrivate, _store.mailJetPublic,
          _store.emailFrom, _store.emailFrom);
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
          mailToReportTo: _store.emailTo);
    }

    // no data lack should occur when program stops here
    // so first delete created directory and then exit
    FileUtils.removeDirectory(backupDir);
    return exit(1);
  }
}
