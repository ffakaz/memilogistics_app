import 'package:flutter/material.dart';

class AppDropdown<T> extends StatelessWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;

  const AppDropdown({super.key, this.value, required this.items, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButton<T>(value: value, items: items, onChanged: onChanged);
  }
}
