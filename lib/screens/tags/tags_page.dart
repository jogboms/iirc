import 'package:flutter/material.dart';
import 'package:iirc/core.dart';
import 'package:iirc/domain.dart';
import 'package:iirc/registry.dart';

import 'tag_list_tile.dart';

// TODO(Jogboms): Improve UI.
class TagsPage extends StatefulWidget {
  const TagsPage({super.key});

  @override
  State<TagsPage> createState() => TagsPageState();
}

@visibleForTesting
class TagsPageState extends State<TagsPage> {
  static const Key loadingViewKey = Key('loadingViewKey');
  static const Key errorViewKey = Key('errorViewKey');

  late final Stream<TagModelList> stream = context.registry.get<FetchTagsUseCase>().call();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.theme.brightness == Brightness.light ? Colors.grey.shade200 : Colors.grey.shade400,
      child: StreamBuilder<TagModelList>(
        stream: stream,
        builder: (BuildContext context, AsyncSnapshot<TagModelList> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              key: loadingViewKey,
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.connectionState == ConnectionState.done && snapshot.hasError) {
            return Center(
              key: errorViewKey,
              child: Text(snapshot.error.toString()),
            );
          }

          final TagModelList tags = snapshot.requireData;

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 24),
            itemBuilder: (BuildContext context, int index) {
              final TagModel tag = tags[index];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: TagListTile(key: Key(tag.id), tag: tag),
              );
            },
            separatorBuilder: (BuildContext context, _) => const SizedBox(height: 8),
            itemCount: tags.length,
          );
        },
      ),
    );
  }
}
