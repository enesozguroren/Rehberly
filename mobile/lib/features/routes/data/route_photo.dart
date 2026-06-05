import 'dart:typed_data';

class RoutePhoto {
  const RoutePhoto({
    required this.id,
    required this.path,
    this.bytes,
  });

  final String id;
  final String path;
  final Uint8List? bytes;

  bool get hasBytes => bytes != null && bytes!.isNotEmpty;

  String get source => hasBytes ? RoutePhotoMemoryStore.uriFor(id) : path;
}

class RoutePhotoMemoryStore {
  RoutePhotoMemoryStore._();

  static const scheme = 'memory://';
  static final Map<String, Uint8List> _images = {};

  static String uriFor(String id) => '$scheme$id';

  static bool isMemoryUri(String source) => source.startsWith(scheme);

  static Uint8List? bytesFor(String source) {
    if (!isMemoryUri(source)) return null;
    return _images[source.substring(scheme.length)];
  }

  static void retain(RoutePhoto photo) {
    final bytes = photo.bytes;
    if (bytes == null || bytes.isEmpty) return;
    _images[photo.id] = bytes;
  }

  static void release(String source) {
    if (!isMemoryUri(source)) return;
    _images.remove(source.substring(scheme.length));
  }
}
