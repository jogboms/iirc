import 'package:flutter/material.dart';
import 'package:iirc/core.dart';
import 'package:iirc/state.dart';

enum TagColorLabelVariant { normal, large }

class TagColorLabel extends StatelessWidget {
  const TagColorLabel({super.key, required this.tag, this.variant = TagColorLabelVariant.normal});

  final TagViewModel tag;
  final TagColorLabelVariant variant;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = context.theme;
    final TextStyle? textStyle =
        variant == TagColorLabelVariant.normal ? theme.textTheme.caption : theme.textTheme.bodyLarge;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: tag.backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        tag.title.capitalize(),
        style: textStyle?.copyWith(
          fontWeight: FontWeight.w400,
          color: tag.foregroundColor,
        ),
      ),
    );
  }
}
