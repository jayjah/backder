import 'package:args/command_runner.dart';
import 'package:backup/backup.dart';
import 'package:test/test.dart';

void main() {
  MakeBackup makeBackup;
  setUp(() {
    makeBackup = MakeBackup();
  });

  tearDown(() {
    makeBackup = null;
  });

  group('MakeBackup Command - Test', () {
    test('[Run]', () async {
      final arguments = <String>['make', '--name testbackup'];
      final testRunner =
          CommandRunner<dynamic>('test-make-backup', 'test-make-backup')
            ..addCommand(makeBackup);
      try {
        await testRunner.run(arguments);
      } catch (e) {
        expect('Arguments Error test-make-backup \n $e', '');
      }

      expect(true, true);
    });
  });
}
