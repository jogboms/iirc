import 'package:flutter/material.dart';
import 'package:iirc/domain.dart';
import 'package:iirc/registry.dart';

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

  late final Stream<List<TagModel>> stream = context.registry.get<FetchTagsUseCase>().call();

  @override
  Widget build(BuildContext context) {
    return Material(
      child: StreamBuilder<List<TagModel>>(
        stream: stream,
        builder: (BuildContext context, AsyncSnapshot<List<TagModel>> snapshot) {
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

          final List<TagModel> tags = snapshot.requireData;

          return ListView.builder(
            itemBuilder: (BuildContext context, int index) {
              final TagModel tag = tags[index];

              return ListTile(
                key: Key(tag.id),
                title: Text(tag.title),
                subtitle: Text(tag.description),
              );
            },
            itemCount: tags.length,
          );
        },
      ),
    );
  }
}
