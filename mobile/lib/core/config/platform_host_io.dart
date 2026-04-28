import 'dart:io' show Platform;

String defaultApiHost() {
  if (Platform.isAndroid) {
    return '10.0.2.2';
  }

  return 'localhost';
}
