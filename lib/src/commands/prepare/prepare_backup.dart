import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:backup/src/storage/model/prepare_model.dart';
import 'package:dcli/dcli.dart' as cli;

import '../../storage/model/storage.dart';
import '../../storage/storage_adapter.dart';

class PrepareBackup extends Command<dynamic> {
  static const String tag = ' :: PrepareBackup :: ';

  PrepareBackup() {
    argParser.addOption('path', help: 'Path to data file');
  }

  @override
  String get description =>
      'Prepares a file with encrypted provided data. This file is used internally when cron starts.';

  @override
  String get name => 'prepare';

  @override
  Future<void> run() async {
    final path = argResults!['path']?.toString();
    if (path == null || path.isEmpty) {
      _stop('ARGUMENT ERROR: file path is missing!');
    }

    final model = _parseAndValidateFileData(path!);

    // create secured local storage && save data in it
    final successfullySaved = await StorageAdapter.put(
      Store.fromData(
          postgresName: model.postgresContainerName,
          serverName: model.serverImagePath,
          mailJetPublic: model.mailjetPublic,
          mailJetPrivate: model.mailjetPrivate,
          emailTo: model.emailTo,
          resticPassword: model.restic,
          emailFrom: model.emailFrom,
          postgresDbName: model.postgresDb,
          postgresDbPw: model.postgresPw,
          resticServerPath: model.resticServerPath,
          postgresDbUser: model.postgresUser),
    );

    if (!successfullySaved) {
      _stop('COULD NOT SAVE DATA!!!!');
    }

    print(cli.green('$tag saved local data!'));
  }

  PrepareModel _parseAndValidateFileData(String path) {
    final model = PrepareModel.fromFile(path);
    if (model == null) {
      _stop('FILE READING ERROR! '
          'Could not read provided file data!');
    }
    if (!model!.hasValidData) {
      _stop('WRONG PARAMETER! '
          'restic password AND at least one docker container must be provided!');
    }
    if (model.postgresContainerName.isNotEmpty &&
        !model.hasValidPostgresCredentiels) {
      _stop('WRONG PARAMETER! '
          'Postgres docker container was named '
          'but additional data is missing. '
          'postgresuser, postgrespw and postgresdb '
          'must be present as provided!');
    }
    return model;
  }

  void _stop(String error) {
    print(cli.red('$tag ERROR! '
        '$error'));
    exit(1);
  }
}
