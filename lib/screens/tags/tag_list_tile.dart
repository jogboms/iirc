import 'package:flutter/material.dart';
import 'package:iirc/core.dart';
import 'package:iirc/domain.dart';
import 'package:iirc/widgets.dart';

import '../home/item_detail_page.dart';

class TagListTile extends StatelessWidget {
  const TagListTile({super.key, required this.tag});

  final TagModel tag;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return AppListTile(
      color: Color(tag.color),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            tag.title.capitalize(),
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            tag.description,
            style: theme.textTheme.bodyMedium,
            maxLines: 2,
          ),
        ],
      ),
      onPressed: () => Navigator.of(context).push<void>(ItemDetailPage.route(id: tag.id)),
    );
  }
}
