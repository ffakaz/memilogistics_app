import 'package:flutter/material.dart';

class AppSearchField extends StatelessWidget {
  final ValueChanged<String>? onChanged;

  const AppSearchField({super.key, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search...'),
    );
  }
}
