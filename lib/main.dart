import 'package:flutter/material.dart';
import 'package:memilogistics_app/app/app.dart';
import 'package:memilogistics_app/bootstrap.dart';

Future<void> main() async {
  await initApp();
  runApp(const MemiLogisticsApp());
}
