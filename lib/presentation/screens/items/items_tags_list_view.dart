import 'package:flutter/material.dart';
import 'package:iirc/domain.dart';

import '../../models.dart';
import '../../theme.dart';
import '../../utils.dart';
import '../tags/create_tag_page.dart';
import '../tags/tag_detail_page.dart';

class ItemsTagsListView extends StatelessWidget {
  const ItemsTagsListView({super.key, required this.tags, required this.analytics});

  final Iterable<TagViewModel> tags;
  final Analytics analytics;

  @visibleForTesting
  static const Key emptyTagsKey = Key('emptyTagsKey');
  @visibleForTesting
  static const Key tagsListKey = Key('tagsListKey');
  @visibleForTesting
  static const Key createTagButtonKey = Key('createTagButtonKey');

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return SizedBox(
      height: kToolbarHeight,
      child: Stack(
        alignment: Alignment.centerRight,
        children: <Widget>[
          if (tags.isEmpty)
            Padding(
              key: emptyTagsKey,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(context.l10n.noTagsCreatedMessage),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(right: 24),
              child: ListView.separated(
                key: tagsListKey,
                padding: const EdgeInsets.only(left: 16, right: 40),
                scrollDirection: Axis.horizontal,
                itemBuilder: (BuildContext context, int index) {
                  final TagViewModel tag = tags.elementAt(index);
                  return ActionChip(
                    key: Key(tag.id),
                    label: Text('#' + tag.title.capitalize()),
                    elevation: 0,
                    shape: const RoundedRectangleBorder(borderRadius: AppBorderRadius.c6),
                    visualDensity: VisualDensity.compact,
                    labelStyle: theme.textTheme.bodyText1?.copyWith(color: tag.foregroundColor),
                    backgroundColor: tag.backgroundColor,
                    onPressed: () {
                      analytics.log(AnalyticsEvent.itemClick('view tag: ${tag.id}'));
                      Navigator.of(context).push<void>(TagDetailPage.route(id: tag.id));
                    },
                  );
                },
                separatorBuilder: (BuildContext context, _) => const SizedBox(width: 8),
                itemCount: tags.length,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: FloatingActionButton.small(
              key: createTagButtonKey,
              onPressed: () {
                analytics.log(AnalyticsEvent.buttonClick('create tag: items'));
                Navigator.of(context).push(CreateTagPage.route());
              },
              elevation: 0,
              tooltip: context.l10n.createTagCaption,
              heroTag: 'CreateTagHeroTag',
              backgroundColor: tags.isEmpty ? colorScheme.primary : colorScheme.mutedBackground,
              foregroundColor: tags.isEmpty ? colorScheme.onPrimary : colorScheme.onMutedBackground,
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}
