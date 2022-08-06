import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iirc/core.dart';
import 'package:iirc/domain.dart';

import '../../models/item_view_model.dart';
import '../../utils/extensions.dart';
import '../../widgets/custom_app_bar.dart';
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
        description: widget.item.description,
        date: widget.item.date,
        tag: widget.item.tag,
        type: ItemEntryType.update,
        onSaved: _onSubmit(context),
      ),
    );
  }

  ItemEntryValueSaved _onSubmit(BuildContext context) {
    return (WidgetRef ref, ItemEntryData data) async {
      try {
        // TODO: Handle loading state.
        await ref.read(itemProvider).update(UpdateItemData(
              id: widget.item.id,
              path: widget.item.path,
              description: data.description,
              date: data.date,
              tag: data.tag.reference,
            ));

        return Navigator.pop(context);
      } catch (error, stackTrace) {
        AppLog.e(error, stackTrace);
        // TODO: Handle error state.
      }
    };
  }
}
