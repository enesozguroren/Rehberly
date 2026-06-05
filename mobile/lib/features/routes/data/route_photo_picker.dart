import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'route_photo.dart';

class RoutePhotoPicker {
  RoutePhotoPicker({ImagePicker? imagePicker})
      : _imagePicker = imagePicker ?? ImagePicker();

  final ImagePicker _imagePicker;

  Future<RoutePhoto?> pickCoverPhoto() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 88,
        maxWidth: 2200,
      );
      if (image == null) return null;
      return _toRoutePhoto(image);
    } on PlatformException catch (error) {
      throw RoutePhotoPickerException.fromPlatform(error);
    } catch (_) {
      throw const RoutePhotoPickerException();
    }
  }

  Future<List<RoutePhoto>> pickStopPhotos() async {
    try {
      final images = await _imagePicker.pickMultiImage(
        imageQuality: 88,
        maxWidth: 2200,
      );
      return Future.wait(images.map(_toRoutePhoto));
    } on PlatformException catch (error) {
      throw RoutePhotoPickerException.fromPlatform(error);
    } catch (_) {
      throw const RoutePhotoPickerException();
    }
  }

  Future<RoutePhoto> _toRoutePhoto(XFile image) async {
    final id = '${DateTime.now().microsecondsSinceEpoch}-${image.name}';
    final photo = RoutePhoto(
      id: id,
      path: image.path,
      bytes: kIsWeb ? await image.readAsBytes() : null,
    );
    RoutePhotoMemoryStore.retain(photo);
    return photo;
  }
}

class RoutePhotoPickerException implements Exception {
  const RoutePhotoPickerException({this.isPermissionDenied = false});

  final bool isPermissionDenied;

  factory RoutePhotoPickerException.fromPlatform(PlatformException error) {
    final code = error.code.toLowerCase();
    return RoutePhotoPickerException(
      isPermissionDenied:
          code.contains('denied') || code.contains('permission'),
    );
  }
}
