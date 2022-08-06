import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models.dart';
import '../theme.dart';
import 'app_list_tile.dart';
import 'tag_color_label.dart';

class ItemListTile extends StatelessWidget {
  const ItemListTile({
    super.key,
    required this.item,
    required this.onPressed,
    this.canShowDate = true,
  });

  final ItemViewModel item;
  final bool canShowDate;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = context.theme;

    return AppListTile(
      tagForegroundColor: item.tag.foregroundColor,
      tagBackgroundColor: item.tag.backgroundColor,
      onPressed: onPressed,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TagColorLabel(tag: item.tag),
                const SizedBox(height: 6),
                Text(
                  item.description,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: AppFontWeight.medium,
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (canShowDate)
            DefaultTextStyle(
              style: theme.textTheme.titleMedium!.copyWith(
                fontWeight: AppFontWeight.semibold,
                color: theme.appTheme.hintColor.shade700,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: theme.appTheme.hintColor.shade200,
                  borderRadius: AppListTile.borderRadius,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(DateFormat('dd').format(item.date)),
                    const SizedBox(height: 2),
                    Text(DateFormat('MMM').format(item.date).toUpperCase()),
                    const SizedBox(height: 2),
                    Text(DateFormat('yy').format(item.date)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
