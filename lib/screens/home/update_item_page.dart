import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iirc/core.dart';
import 'package:iirc/data.dart';
import 'package:iirc/domain.dart';
import 'package:iirc/widgets.dart';

import 'item_entry_form.dart';
import 'providers/item_provider.dart';

class UpdateItemPage extends StatefulWidget {
  const UpdateItemPage({super.key, required this.item});

  static PageRoute<void> route({required ItemViewModel item}) {
    return MaterialPageRoute<void>(builder: (_) => UpdateItemPage(item: item));
  }

  final ItemViewModel item;

  @override
  State<UpdateItemPage> createState() => UpdateItemPageState();
}

@visibleForTesting
class UpdateItemPageState extends State<UpdateItemPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Text(context.l10n.updateItemCaption),
      ),
      body: ItemEntryForm(
        initialValue: ItemEntryData(
          description: widget.item.description,
          date: widget.item.date,
          tag: widget.item.tag,
        ),
        type: ItemEntryType.create,
        onSaved: _onSubmit(context),
      ),
    );
  }

  ItemEntryValueSaved _onSubmit(BuildContext context) {
    return (WidgetRef ref, ItemEntryData data) async {
      await ref.read(itemProvider).update(UpdateItemData(
            id: widget.item.id,
            path: widget.item.path,
            description: data.description,
            date: data.date,
            tag: data.tag!.reference,
          ));

      // TODO: Handle loading state.
      // TODO: Handle error state.

      return Navigator.pop(context);
    };
  }
}
