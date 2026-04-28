import 'package:flutter/material.dart';

class RouteSearchBar extends StatelessWidget {
  const RouteSearchBar({
    super.key,
    required this.onChanged,
    this.onFilterTap,
  });

  final ValueChanged<String> onChanged;
  final VoidCallback? onFilterTap;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Destinasyon, rota veya gezgin ara',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: IconButton(
          tooltip: 'Filtreler',
          onPressed: onFilterTap,
          icon: const Icon(Icons.tune_rounded),
        ),
      ),
    );
  }
}
