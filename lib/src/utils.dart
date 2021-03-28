import 'dart:io';

import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:dcli/dcli.dart' as cli;

abstract class DockerUtils {
  // checks if a container is running
  static bool isContainerReachable(String containerName) {
    var isReachable = false;
    final containers = 'docker container ls'.toList(skipLines: 1);

    for (final container in containers) {
      if (container.contains(containerName)) {
        isReachable = true;
      }
    }
    print('Is docker container ( $containerName ) running? $isReachable ...\n');

    return isReachable;
  }
}

abstract class FileUtils {
  static void createDirectory(String path) =>
      cli.createDir(path, recursive: true);

  static void removeDirectory(String path) =>
      cli.deleteDir(path, recursive: true);

  static String? compressDirectory(String path) {
    final archive = createArchiveFromDirectory(Directory(path));
    // Encode the archive as a Zip compressed file.
    final zip_data = ZipEncoder().encode(archive);
    if (zip_data == null) {
      return null;
    }

    final backupFileName = '${path}backup.zip';

    // Write the compressed Zip file to disk.
    final compressedBackupFile = File(backupFileName);
    compressedBackupFile.writeAsBytesSync(zip_data);

    return backupFileName;
  }
}
