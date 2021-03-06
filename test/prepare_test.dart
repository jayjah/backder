import 'package:args/command_runner.dart';
import 'package:backup/backup.dart';
import 'package:dcli/dcli.dart';
import 'package:test/test.dart';

void main() {
  late PrepareBackup prepare;
  setUp(() {
    prepare = PrepareBackup();
  });

  group('Prepare Command - Test', () {
    test('[Run]', () async {
      final arguments = <String>[
        'prepare',
        '--path ${'pwd'.firstLine}/.backup.json',
      ];
      final testRunner = CommandRunner<dynamic>('test-prepare', 'test-prepare')
        ..addCommand(prepare);
      try {
        await testRunner.run(arguments);
      } catch (e) {
        expect('Arguments Error test-make-prepare \n $e', '');
      }

      expect(true, true);
    });
  });
}
