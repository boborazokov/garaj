import 'dart:io';

Future<void> deleteFileIfExists(String path) async {
  try {
    final f = File(path);
    if (await f.exists()) await f.delete();
  } catch (_) {
    // Best-effort cleanup: ignore.
  }
}

bool fileExistsSync(String path) {
  try {
    return File(path).existsSync();
  } catch (_) {
    return false;
  }
}

bool get platformIsWindows => Platform.isWindows;
