import 'package:flutter/material.dart';

class TextScaleWrapper extends StatelessWidget {
  final Widget child;
  const TextScaleWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
        child: child);
  }
}
