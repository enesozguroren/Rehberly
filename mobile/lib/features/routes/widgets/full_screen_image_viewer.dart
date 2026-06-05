import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../data/route_photo.dart';
import 'platform_local_image.dart';

class FullScreenImageViewer extends StatelessWidget {
  const FullScreenImageViewer({
    super.key,
    required this.source,
    required this.fallbackAsset,
  });

  final String? source;
  final String fallbackAsset;

  static Future<void> show(
    BuildContext context, {
    required String? source,
    required String fallbackAsset,
  }) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.88),
      builder: (_) => FullScreenImageViewer(
        source: source,
        fallbackAsset: fallbackAsset,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      backgroundColor: Colors.transparent,
      child: Stack(
        children: [
          Positioned.fill(
            child: InteractiveViewer(
              minScale: 0.8,
              maxScale: 4.5,
              child: Center(
                child: _ViewerImage(
                  source: source,
                  fallbackAsset: fallbackAsset,
                ),
              ),
            ),
          ),
          Positioned(
            right: 16,
            top: MediaQuery.paddingOf(context).top + 10,
            child: IconButton.filled(
              tooltip: 'Kapat',
              style: IconButton.styleFrom(
                backgroundColor: Colors.black.withValues(alpha: 0.52),
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close_rounded),
            ),
          ),
          Positioned(
            left: 16,
            bottom: MediaQuery.paddingOf(context).bottom + 18,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.42),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white24),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.zoom_out_map_rounded,
                      color: AppTheme.card,
                      size: 16,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Yakınlaştırmak için sıkıştır',
                      style: TextStyle(
                        color: AppTheme.card,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ViewerImage extends StatelessWidget {
  const _ViewerImage({
    required this.source,
    required this.fallbackAsset,
  });

  final String? source;
  final String fallbackAsset;

  @override
  Widget build(BuildContext context) {
    final resolved = source?.trim();
    if (resolved == null || resolved.isEmpty) {
      return Image.asset(fallbackAsset, fit: BoxFit.contain);
    }

    final memoryBytes = RoutePhotoMemoryStore.bytesFor(resolved);
    if (memoryBytes != null) {
      return Image.memory(
        memoryBytes,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) =>
            Image.asset(fallbackAsset, fit: BoxFit.contain),
      );
    }

    if (resolved.startsWith('http://') || resolved.startsWith('https://')) {
      return Image.network(
        resolved,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) =>
            Image.asset(fallbackAsset, fit: BoxFit.contain),
      );
    }

    return localImage(
      resolved,
      fit: BoxFit.contain,
      fallback: () => Image.asset(fallbackAsset, fit: BoxFit.contain),
    );
  }
}
