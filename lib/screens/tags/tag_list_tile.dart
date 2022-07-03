import 'package:flutter/material.dart';
import 'package:iirc/domain.dart';
import 'package:iirc/widgets.dart';

class TagListTile extends StatelessWidget {
  const TagListTile({super.key, required this.tag, required this.onPressed});

  final TagModel tag;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => AppListTile(
        title: Text(tag.title),
        subtitle: Text(tag.description),
        trailing: TagColorBox(key: ValueKey<int>(tag.color), code: tag.color),
        onPressed: onPressed,
      );
}
