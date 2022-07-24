import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iirc/core.dart';
import 'package:iirc/state.dart';
import 'package:iirc/widgets.dart';

import '../widgets/search_bar.dart';
import 'providers/filtered_tags_state_provider.dart';
import 'tag_list_tile.dart';

class TagsPage extends StatefulWidget {
  const TagsPage({super.key});

  @override
  State<TagsPage> createState() => TagsPageState();
}

@visibleForTesting
class TagsPageState extends State<TagsPage> {
  static const Key dataViewKey = Key('dataViewKey');

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) => ref.watch(filteredTagsStateProvider).when(
            data: (TagViewModelList data) => _TagsDataView(key: dataViewKey, tags: data),
            error: ErrorView.new,
            loading: () => child!,
          ),
      child: const LoadingView(),
    );
  }
}

class _TagsDataView extends StatelessWidget {
  const _TagsDataView({super.key, required this.tags});

  final TagViewModelList tags;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        const CustomAppBar(
          title: SearchBar(),
          asSliver: true,
          centerTitle: true,
        ),
        if (tags.isEmpty)
          SliverFillRemaining(
            child: Center(
              child: Text(context.l10n.noTagsCreatedMessage),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            sliver: SliverList(
              delegate: SliverSeparatorBuilderDelegate(
                builder: (BuildContext context, int index) {
                  final TagViewModel tag = tags[index];

                  return TagListTile(key: Key(tag.id), tag: tag);
                },
                separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 8),
                childCount: tags.length,
              ),
            ),
          )
      ],
    );
  }
}
