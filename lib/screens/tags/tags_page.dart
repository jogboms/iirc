import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iirc/core.dart';
import 'package:iirc/domain.dart';
import 'package:iirc/widgets.dart';

import 'providers/tags_provider.dart';
import 'tag_list_tile.dart';

// TODO(Jogboms): Improve UI.
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
    return Material(
      color: context.theme.brightness == Brightness.light ? Colors.grey.shade200 : Colors.grey.shade400,
      child: Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) => ref.watch(tagsStateProvider).when(
              data: (TagModelList data) => _TagsDataView(key: dataViewKey, tags: data),
              error: ErrorView.new,
              loading: () => child!,
            ),
        child: const LoadingView(),
      ),
    );
  }
}

class _TagsDataView extends StatelessWidget {
  const _TagsDataView({super.key, required this.tags});

  final TagModelList tags;

  @override
  Widget build(BuildContext context) => ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        itemBuilder: (BuildContext context, int index) {
          final TagModel tag = tags[index];

          return TagListTile(key: Key(tag.id), tag: tag);
        },
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemCount: tags.length,
      );
}
