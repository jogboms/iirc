import 'package:flutter/material.dart';
import 'package:iirc/core.dart';
import 'package:iirc/data.dart';
import 'package:iirc/widgets.dart';
import 'package:intl/intl.dart';

import '../tags/tag_detail_page.dart';

class ItemListTile extends StatelessWidget {
  const ItemListTile({
    super.key,
    required this.item,
    this.canShowDate = true,
    this.canNavigate = true,
  });

  final ItemViewModel item;
  final bool canShowDate;
  final bool canNavigate;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return AppListTile(
      tagForegroundColor: item.tag.foregroundColor,
      tagBackgroundColor: item.tag.backgroundColor,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: item.tag.backgroundColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    item.tag.title.capitalize(),
                    style: theme.textTheme.caption?.copyWith(
                      fontWeight: FontWeight.w400,
                      color: item.tag.foregroundColor,
                    ),
                  ),
                ),
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
      onPressed: () => canNavigate ? Navigator.of(context).push<void>(TagDetailPage.route(id: item.tag.id)) : null,
    );
  }
}
