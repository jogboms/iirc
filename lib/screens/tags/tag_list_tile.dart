import 'package:flutter/material.dart';
import 'package:iirc/domain.dart';
import 'package:iirc/widgets.dart';

import '../home/item_detail_page.dart';

class TagListTile extends StatelessWidget {
  const TagListTile({super.key, required this.tag});

  final TagModel tag;

  @override
  Widget build(BuildContext context) => AppListTile(
        title: Text(tag.title),
        subtitle: Text(tag.description),
        trailing: TagColorBox(key: ValueKey<int>(tag.color), code: tag.color),
        onPressed: () => Navigator.of(context).push<void>(ItemDetailPage.route(context, id: tag.id)),
      );
}
