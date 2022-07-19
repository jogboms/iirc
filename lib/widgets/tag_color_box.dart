import 'package:flutter/material.dart';

class TagColorBox extends StatelessWidget {
  const TagColorBox({super.key, required this.code}) : dimension = 16;

  const TagColorBox.large({super.key, required this.code}) : dimension = 24;

  final int code;
  final double dimension;

  @override
  Widget build(BuildContext context) {
    final Color color = Color(code);

    return Material(
      shape: const CircleBorder(),
      color: color,
      child: SizedBox.square(dimension: dimension),
    );
  }
}
