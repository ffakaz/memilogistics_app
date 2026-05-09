import 'package:flutter/material.dart';

class AppAvatar extends StatelessWidget {
  final String? url;
  final String initials;

  const AppAvatar({super.key, this.url, this.initials = '?'});

  @override
  Widget build(BuildContext context) => CircleAvatar(backgroundImage: url == null ? null : NetworkImage(url!), child: url == null ? Text(initials) : null);
}
