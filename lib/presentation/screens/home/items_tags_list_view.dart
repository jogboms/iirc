import 'package:flutter/material.dart';

import '../../models.dart';
import '../../theme.dart';
import '../../utils.dart';
import '../tags/create_tag_page.dart';

class ItemsTagsListView extends StatelessWidget {
  const ItemsTagsListView({super.key, required this.tags});

  final Iterable<TagViewModel> tags;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return SizedBox(
      height: kToolbarHeight,
      child: Stack(
        alignment: Alignment.centerRight,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ListView.separated(
              padding: const EdgeInsets.only(left: 16, right: 40),
              scrollDirection: Axis.horizontal,
              itemBuilder: (BuildContext context, int index) {
                final TagViewModel tag = tags.elementAt(index);
                return Chip(
                  key: Key(tag.id),
                  label: Text('#' + tag.title.capitalize()),
                  elevation: 0,
                  shape: const RoundedRectangleBorder(borderRadius: AppBorderRadius.c6),
                  visualDensity: VisualDensity.compact,
                  labelStyle: theme.textTheme.bodyText1?.copyWith(color: tag.foregroundColor),
                  backgroundColor: tag.backgroundColor,
                );
              },
              separatorBuilder: (BuildContext context, _) => const SizedBox(width: 8),
              itemCount: tags.length,
            ),
          ),
          FloatingActionButton.small(
            onPressed: () => Navigator.of(context).push(CreateTagPage.route()),
            elevation: 0,
            tooltip: context.l10n.createTagCaption,
            heroTag: 'CreateTagHeroTag',
            backgroundColor: colorScheme.mutedBackground,
            foregroundColor: colorScheme.onMutedBackground,
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
