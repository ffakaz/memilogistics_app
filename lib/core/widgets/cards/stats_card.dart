import 'package:flutter/material.dart';
import 'app_card.dart';

class StatsCard extends StatelessWidget {
  final String label;
  final String value;

  const StatsCard({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => AppCard(child: Column(children: [Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text(label)]));
}
