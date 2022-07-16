import 'package:flutter/material.dart';
import 'package:iirc/core.dart';
import 'package:iirc/domain.dart';
import 'package:iirc/widgets.dart';
import 'package:intl/intl.dart';

import 'item_detail_page.dart';

class ItemListTile extends StatelessWidget {
  const ItemListTile({super.key, required this.item});

  final ItemModel item;

  @override
  Widget build(BuildContext context) => AppListTile(
        title: Text(item.title),
        subtitle: Text(DateFormat().format(item.date)),
        trailing: _Tag(key: Key(item.tag.id), tag: item.tag),
        onPressed: () => Navigator.of(context).push<void>(ItemDetailPage.route(context, id: item.tag.id)),
      );
}

class _Tag extends StatelessWidget {
  const _Tag({super.key, required this.tag});

  final TagModel tag;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = context.theme;
    final Color color = Color(tag.color);

    return Material(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
      color: color,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          key: Key(tag.id),
          tag.title,
          style: theme.textTheme.labelMedium?.copyWith(
            color: Color.lerp(color, Colors.black, .75),
          ),
        ),
      ),
    );
  }
}
