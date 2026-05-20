import 'package:flutter/material.dart';
import 'package:memilogistics_app/app/app.dart';
import 'package:memilogistics_app/bootstrap.dart';
import 'package:memilogistics_app/core/config/api_config.dart';

Future<void> main() async {
  await initApp(env: AppEnvironment.development);
  runApp(const MemiLogisticsApp());
}
