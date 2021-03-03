import 'package:hive/hive.dart';

part 'storage.g.dart';

@HiveType(typeId: 0)
class Store extends HiveObject {
  Store();

  Store.fromData(
      {String mailJetPublic,
      String mailJetPrivate,
      String emailFrom,
      String emailTo,
      String postgresName,
      String serverName,
      String postgresDbName,
      String postgresDbUser,
      String postgresDbPw}) {
    this
      ..emailTo = emailTo ?? ''
      ..emailFrom = emailFrom ?? ''
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
  String emailFrom;

  @HiveField(5)
  String emailTo;

  @HiveField(6)
  String postgresDbUser;

  @HiveField(7)
  String postgresDbPw;

  @HiveField(8)
  String postgresDbName;

  @HiveField(9)
  String resticPassword;

  bool get mailDataProvided =>
      mailJetPrivate != null &&
      mailJetPrivate.isNotEmpty &&
      mailJetPublic != null &&
      mailJetPublic.isNotEmpty &&
      emailFrom != null &&
      emailFrom.isNotEmpty &&
      emailTo != null &&
      emailTo.isNotEmpty;

  bool get postgresDataProvided =>
      postgresDbName != null &&
      postgresDbName.isNotEmpty &&
      postgresDbPw != null &&
      postgresDbPw.isNotEmpty &&
      postgresDbUser != null &&
      postgresDbUser.isNotEmpty;
}
