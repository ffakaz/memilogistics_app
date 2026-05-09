import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;

  const AppTextField({super.key, this.controller, this.hintText});

  @override
  Widget build(BuildContext context) {
    return TextField(controller: controller, decoration: InputDecoration(hintText: hintText));
  }
}
