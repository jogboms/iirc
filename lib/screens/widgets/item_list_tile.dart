import 'package:flutter/material.dart';
import 'package:iirc/core.dart';
import 'package:iirc/data.dart';
import 'package:iirc/widgets.dart';
import 'package:intl/intl.dart';

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
                  style: theme.textTheme.labelLarge,
                  maxLines: 2,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (canShowDate)
            DefaultTextStyle(
              style: theme.textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade700,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
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
