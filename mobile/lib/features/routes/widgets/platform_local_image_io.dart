import 'dart:io';

import 'package:flutter/widgets.dart';

Widget localImage(
  String path, {
  required BoxFit fit,
  required Widget Function() fallback,
}) {
  return Image.file(
    File(path),
    fit: fit,
    errorBuilder: (_, __, ___) => fallback(),
  );
}
