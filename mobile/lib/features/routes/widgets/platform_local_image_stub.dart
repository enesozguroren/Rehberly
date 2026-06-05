import 'package:flutter/widgets.dart';

Widget localImage(
  String path, {
  required BoxFit fit,
  required Widget Function() fallback,
}) {
  return Image.network(
    path,
    fit: fit,
    errorBuilder: (_, __, ___) => fallback(),
  );
}
