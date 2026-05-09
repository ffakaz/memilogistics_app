import 'package:flutter/material.dart';

class AppPhoneField extends StatelessWidget {
  final TextEditingController? controller;

  const AppPhoneField({super.key, this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(controller: controller, keyboardType: TextInputType.phone, decoration: const InputDecoration(hintText: 'Phone'));
  }
}
