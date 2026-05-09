import 'package:flutter/material.dart';

class NetworkErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;

  const NetworkErrorWidget({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [const Text('Network error'), ElevatedButton(onPressed: onRetry, child: const Text('Retry'))]);
  }
}
