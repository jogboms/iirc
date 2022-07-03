import 'package:flutter/material.dart';
import 'package:iirc/core.dart';
import 'package:iirc/domain.dart';

class TagListTile extends StatelessWidget {
  const TagListTile({super.key, required this.tag});

  final TagModel tag;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = context.theme;

    return Material(
      color: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(6))),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    tag.title,
                    style: theme.textTheme.bodyLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tag.description,
                    style: theme.textTheme.labelMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _TagColor(key: Key(tag.id), code: tag.color)
          ],
        ),
      ),
    );
  }
}

class _TagColor extends StatelessWidget {
  const _TagColor({super.key, required this.code});

  final int code;

  @override
  Widget build(BuildContext context) {
    final Color color = Color(code);

    return Material(
      shape: const CircleBorder(),
      color: color,
      child: const SizedBox.square(dimension: 16),
    );
  }
}
