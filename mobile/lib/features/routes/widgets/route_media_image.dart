import 'package:flutter/material.dart';

import '../data/route_photo.dart';
import 'full_screen_image_viewer.dart';
import 'platform_local_image.dart';

class RouteMediaImage extends StatelessWidget {
  const RouteMediaImage({
    super.key,
    required this.source,
    required this.fallbackAsset,
    this.fit = BoxFit.cover,
    this.enableFullScreen = true,
  });

  final String? source;
  final String fallbackAsset;
  final BoxFit fit;
  final bool enableFullScreen;

  @override
  Widget build(BuildContext context) {
    final image = _buildImage();
    if (!enableFullScreen) return image;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FullScreenImageViewer.show(
        context,
        source: source,
        fallbackAsset: fallbackAsset,
      ),
      child: image,
    );
  }

  Widget _buildImage() {
    final resolved = source?.trim();
    if (resolved == null || resolved.isEmpty) {
      return Image.asset(fallbackAsset, fit: fit);
    }

    final memoryBytes = RoutePhotoMemoryStore.bytesFor(resolved);
    if (memoryBytes != null) {
      return Image.memory(
        memoryBytes,
        fit: fit,
        errorBuilder: (_, __, ___) => Image.asset(fallbackAsset, fit: fit),
      );
    }

    if (resolved.startsWith('http://') || resolved.startsWith('https://')) {
      return Image.network(
        resolved,
        fit: fit,
        errorBuilder: (_, __, ___) => Image.asset(fallbackAsset, fit: fit),
      );
    }

    return localImage(
      resolved,
      fit: fit,
      fallback: () => Image.asset(fallbackAsset, fit: fit),
    );
  }
}
