import 'package:backup/backup.dart';
import 'package:dcli/dcli.dart';
import 'package:hive/hive.dart';
import 'package:test/test.dart';

void main() {
  const serverName = 'test';
  Hive.init('${'pwd'.firstLine}');
  Hive.registerAdapter(StoreAdapter());

  tearDown(() {
    StorageAdapter.boxKey = '';
  });

  group('Storage - Test', () {
    test('[Save]', () async {
      StorageAdapter.boxKey = '314428472B4B6250655368566D597132';

      final saved =
          await StorageAdapter.put(Store()..serverImagePath = serverName);
      expect(saved, true);
    });
    test('[Get]', () async {
      StorageAdapter.boxKey = '314428472B4B6250655368566D597132';

      final store = await StorageAdapter.get();
      expect(store, isNotNull);
      expect(store?.serverImagePath, serverName);
    });
  });
}
