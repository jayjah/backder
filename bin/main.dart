import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:backup/backup.dart';
import 'package:dcli/dcli.dart';
import 'package:hive/hive.dart';

Future<void> main(List<String> arguments) async {
  // init local secured storage
  Hive.init('${'pwd'.firstLine}');
  Hive.registerAdapter(StoreAdapter());

  // set key for encryption
  StorageAdapter.boxKey = '314428472B4B6250655368566D597132';

  await readAndParseArguments(arguments);
  return exit(0);
}

Future<dynamic> readAndParseArguments(List<String> arguments) async {
  final runner = CommandRunner<dynamic>('backup',
      'Helper to provide compressed data from docker containers for backups. Provides email support for error handling')
    ..addCommand(PrepareBackup())
    ..addCommand(MakeBackup());

  try {
    return await runner.run(arguments);
  } catch (e) {
    print(red('Could not read and parse command line arguments \n $e'));
  }

  return null;
}
