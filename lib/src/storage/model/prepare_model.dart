import 'dart:convert';
import 'dart:io';

import 'package:dcli/dcli.dart' as cli;

class PrepareModel {
  PrepareModel();
  static PrepareModel fromFile(String path) {
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
      ..serverContainerName = map['serverDockerContainerName']
      ..postgresPw = map['postgresPw']
      ..postgresUser = map['postgresUser']
      ..postgresDb = map['postgresDb']
      ..postgresContainerName = map['postgresDockerContainerName']
      ..restic = map['restic']
      ..mailjetPublic = map['mailjetPublic']
      ..mailjetPrivate = map['mailjetPrivate']
      ..fromErrorMail = map['fromErrorMail'];
  }

  String postgresUser;
  String postgresPw;
  String postgresDb;
  String postgresContainerName;
  String serverContainerName;
  String mailjetPublic;
  String mailjetPrivate;
  String fromErrorMail;
  String restic;

  bool get hasValidData {
    if ((serverContainerName == null && postgresContainerName == null) ||
        restic == null) {
      false;
    }
    return true;
  }

  bool get hasValidPostgresCredentiels =>
      postgresUser != null && postgresDb != null && postgresPw != null;
}
