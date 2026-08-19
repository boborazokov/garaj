/// Web stubs: there's no filesystem; recorded media lives in browser-managed
/// blob URLs that get garbage-collected automatically.
Future<void> deleteFileIfExists(String _) async {}

bool fileExistsSync(String _) => false;

bool get platformIsWindows => false;
