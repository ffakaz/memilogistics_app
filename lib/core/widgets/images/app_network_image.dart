import 'package:flutter/material.dart';

class AppNetworkImage extends StatelessWidget {
  final String url;
  final double? width, height;

  const AppNetworkImage({super.key, required this.url, this.width, this.height});

  @override
  Widget build(BuildContext context) => Image.network(url, width: width, height: height, fit: BoxFit.cover);
}
