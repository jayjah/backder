import 'package:hive/hive.dart';

part 'storage.g.dart';

@HiveType(typeId: 0)
class Store extends HiveObject {
  Store();

  Store.fromData(
      {String? mailJetPublic,
      String? mailJetPrivate,
      String? emailFrom,
      String? emailTo,
      String? postgresName,
      String? serverName,
      String? postgresDbName,
      String? postgresDbUser,
      String? postgresDbPw}) {
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
  late String postgresName;

  @HiveField(1)
  late String serverName;

  @HiveField(2)
  late String mailJetPublic;

  @HiveField(3)
  late String mailJetPrivate;

  @HiveField(4)
  late String emailFrom;

  @HiveField(5)
  late String emailTo;

  @HiveField(6)
  late String postgresDbUser;

  @HiveField(7)
  late String postgresDbPw;

  @HiveField(8)
  late String postgresDbName;

  @HiveField(9)
  late String resticPassword;

  bool get mailDataProvided =>
      mailJetPrivate.isNotEmpty &&
      mailJetPublic.isNotEmpty &&
      emailFrom.isNotEmpty &&
      emailTo.isNotEmpty;

  bool get postgresDataProvided =>
      postgresDbName.isNotEmpty &&
      postgresDbPw.isNotEmpty &&
      postgresDbUser.isNotEmpty;
}
