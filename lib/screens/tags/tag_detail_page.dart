import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iirc/domain.dart';

import 'providers/selected_tag_provider.dart';

class TagDetailPage extends StatefulWidget {
  const TagDetailPage({super.key});

  static Future<void> go(BuildContext context) {
    return Navigator.of(context).push<void>(MaterialPageRoute<void>(builder: (_) => const TagDetailPage()));
  }

  @override
  State<TagDetailPage> createState() => _TagDetailPageState();
}

class _TagDetailPageState extends State<TagDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) {
          final TagModel? item = ref.read(selectedTagProvider);

          if (item == null) {
            return const Center(
              child: Text('No item'),
            );
          }

          return Text(item.id);
        },
      ),
    );
  }
}
