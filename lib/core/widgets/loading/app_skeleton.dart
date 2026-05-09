import 'package:flutter/material.dart';

class AppSkeleton extends StatelessWidget {
  const AppSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: List.generate(3, (i) => Container(margin: const EdgeInsets.symmetric(vertical: 8), height: 16, color: Colors.grey.shade300)));
  }
}
