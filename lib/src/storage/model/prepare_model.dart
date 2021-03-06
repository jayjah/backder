import 'dart:convert';
import 'dart:io';

import 'package:dcli/dcli.dart' as cli;

class PrepareModel {
  PrepareModel();
  static PrepareModel? fromFile(String path) {
    final input = File(path);
    if (!input.existsSync()) {
      return null;
    }
    var map;
    try {
      map = jsonDecode(
        utf8.decode(
          input.readAsBytesSync(),
        ),
      );
    } catch (e) {
      print(cli.red('PrepareModel :: fromFile :: PARSE ERROR $e'));
      return null;
    }

    if (map is! Map) {
      print(cli.red(
          'WRONG DATA FORMAT - SHOULD BE A SIMPLE JSON OBJECT: "{ ... }"!'));
      return null;
    }

    return PrepareModel()
      ..serverContainerName = map['serverDockerContainerName'] ?? ''
      ..postgresPw = map['postgresPw'] ?? ''
      ..postgresUser = map['postgresUser'] ?? ''
      ..postgresDb = map['postgresDb'] ?? ''
      ..postgresContainerName = map['postgresDockerContainerName'] ?? ''
      ..restic = map['restic'] ?? ''
      ..mailjetPublic = map['mailjetPublic'] ?? ''
      ..mailjetPrivate = map['mailjetPrivate'] ?? ''
      ..emailTo = map['emailTo'] ?? ''
      ..emailFrom = map['emailFrom'] ?? '';
  }

  late String postgresUser;
  late String postgresPw;
  late String postgresDb;
  late String postgresContainerName;
  late String serverContainerName;
  late String mailjetPublic;
  late String mailjetPrivate;
  late String emailTo;
  late String emailFrom;
  late String restic;

  bool get hasValidData {
    if ((serverContainerName.isEmpty && postgresContainerName.isEmpty) ||
        restic.isEmpty) {
      false;
    }
    return true;
  }

  bool get hasValidPostgresCredentiels =>
      postgresUser.isNotEmpty && postgresDb.isNotEmpty && postgresPw.isNotEmpty;
}
