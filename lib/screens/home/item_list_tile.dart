import 'package:flutter/material.dart';
import 'package:iirc/core.dart';
import 'package:iirc/domain.dart';
import 'package:iirc/widgets.dart';
import 'package:intl/intl.dart';

import 'item_detail_page.dart';

class ItemListTile extends StatelessWidget {
  const ItemListTile({
    super.key,
    required this.item,
    this.canShowDate = true,
    this.canNavigate = true,
  });

  final ItemModel item;
  final bool canShowDate;
  final bool canNavigate;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color color = Color(item.tag.color);
    final Brightness colorBrightness = ThemeData.estimateBrightnessForColor(color);

    return AppListTile(
      color: color,
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
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    item.tag.title.capitalize(),
                    style: theme.textTheme.caption?.copyWith(
                      fontWeight: FontWeight.w400,
                      color: colorBrightness == Brightness.light ? Colors.black : Colors.white,
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
      onPressed: () => canNavigate ? Navigator.of(context).push<void>(ItemDetailPage.route(id: item.tag.id)) : null,
    );
  }
}
