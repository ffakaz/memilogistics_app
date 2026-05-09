import 'package:flutter/material.dart';

class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key});

  @override
  Widget build(BuildContext context) => IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).maybePop());
}
