import 'package:flutter/material.dart';
import 'package:iirc/domain.dart';
import 'package:iirc/widgets/app_list_tile.dart';

class TagListTile extends StatelessWidget {
  const TagListTile({super.key, required this.tag});

  final TagModel tag;

  @override
  Widget build(BuildContext context) => AppListTile(
        title: Text(tag.title),
        subtitle: Text(tag.description),
        trailing: _TagColor(key: Key(tag.id), code: tag.color),
      );
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
