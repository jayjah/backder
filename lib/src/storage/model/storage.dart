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
      String? serverImagePath,
      String? postgresDbName,
      String? resticPassword,
      String? resticServerPath,
      String? postgresDbUser,
      String? postgresDbPw,
      String? logglyPath,
      String? servercontainerName,
      String? healthcarePath}) {
    this
      ..emailTo = emailTo ?? ''
      ..emailFrom = emailFrom ?? ''
      ..postgresName = postgresName ?? ''
      ..serverImagePath = serverImagePath ?? ''
      ..mailJetPublic = mailJetPublic ?? ''
      ..mailJetPrivate = mailJetPrivate ?? ''
      ..postgresDbName = postgresDbName ?? ''
      ..postgresDbUser = postgresDbUser ?? ''
      ..resticPassword = resticPassword ?? ''
      ..resticServerPath = resticServerPath ?? ''
      ..healthCarePath = healthcarePath ?? ''
      ..serverContainerName = servercontainerName ?? ''
      ..logglyPath = logglyPath ?? ''
      ..postgresDbPw = postgresDbPw ?? '';
  }

  @HiveField(0)
  late String postgresName;

  @HiveField(1)
  late String serverImagePath;

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

  @HiveField(10)
  late String resticServerPath;

  @HiveField(11)
  late String healthCarePath;

  @HiveField(12)
  late String serverContainerName;

  @HiveField(13)
  late String logglyPath;

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
