import 'package:hive/hive.dart';

part 'storage.g.dart';

@HiveType(typeId: 0)
class Store extends HiveObject {
  Store();

  Store.fromData(
      {String mailJetPublic,
      String mailJetPrivate,
      String email,
      String postgresName,
      String serverName,
      String postgresDbName,
      String postgresDbUser,
      String postgresDbPw}) {
    this
      ..errorReportMail = email ?? ''
      ..postgresName = postgresName ?? ''
      ..serverName = serverName ?? ''
      ..mailJetPublic = mailJetPublic ?? ''
      ..mailJetPrivate = mailJetPrivate ?? ''
      ..postgresDbName = postgresDbName ?? ''
      ..postgresDbUser = postgresDbUser ?? ''
      ..postgresDbPw = postgresDbPw ?? '';
  }

  @HiveField(0)
  String postgresName;

  @HiveField(1)
  String serverName;

  @HiveField(2)
  String mailJetPublic;

  @HiveField(3)
  String mailJetPrivate;

  @HiveField(4)
  String errorReportMail;

  @HiveField(5)
  String postgresDbUser;

  @HiveField(6)
  String postgresDbPw;

  @HiveField(7)
  String postgresDbName;

  @HiveField(8)
  String resticPassword;

  bool get mailDataProvided =>
      mailJetPrivate != null &&
      mailJetPrivate.isNotEmpty &&
      mailJetPublic != null &&
      mailJetPublic.isNotEmpty &&
      errorReportMail != null &&
      errorReportMail.isNotEmpty;

  bool get postgresDataProvided =>
      postgresDbName != null &&
      postgresDbName.isNotEmpty &&
      postgresDbPw != null &&
      postgresDbPw.isNotEmpty &&
      postgresDbUser != null &&
      postgresDbUser.isNotEmpty;
}
