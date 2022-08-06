import 'package:flutter/material.dart';

import '../../models.dart';
import '../../theme.dart';
import '../../utils.dart';
import '../../widgets.dart';
import 'tag_detail_page.dart';

class TagListTile extends StatelessWidget {
  const TagListTile({super.key, required this.tag});

  final TagViewModel tag;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = context.theme;

    return AppListTile(
      tagForegroundColor: tag.foregroundColor,
      tagBackgroundColor: tag.backgroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            tag.title.capitalize(),
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: AppFontWeight.medium,
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
      onPressed: () => Navigator.of(context).push<void>(TagDetailPage.route(id: tag.id)),
    );
  }
}
