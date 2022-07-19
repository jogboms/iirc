import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iirc/core.dart';
import 'package:iirc/domain.dart';
import 'package:iirc/screens.dart';
import 'package:iirc/widgets.dart';

import 'item_entry_form.dart';
import 'providers/item_provider.dart';

class CreateItemPage extends StatefulWidget {
  const CreateItemPage({super.key, required this.asModal, this.date, this.tag});

  static PageRoute<void> route({bool asModal = false, DateTime? date, TagModel? tag}) {
    return MaterialPageRoute<void>(builder: (_) => CreateItemPage(asModal: asModal, date: date, tag: tag));
  }

  final bool asModal;
  final DateTime? date;
  final TagModel? tag;

  @override
  State<CreateItemPage> createState() => CreateItemPageState();
}

@visibleForTesting
class CreateItemPageState extends State<CreateItemPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Text(context.l10n.createItemCaption),
      ),
      body: ItemEntryForm(
        initialValue: ItemEntryData(
          description: '',
          date: widget.date ?? clock.now(),
          tag: widget.tag,
        ),
        type: ItemEntryType.create,
        onSaved: _onSubmit(context),
      ),
    );
  }

  ItemEntryValueSaved _onSubmit(BuildContext context) {
    return (WidgetRef ref, ItemEntryData data) async {
      final ItemModel item = await ref.read(itemProvider).create(CreateItemData(
            description: data.description,
            date: data.date,
            tag: data.tag,
          ));

      // TODO: Handle loading state.
      // TODO: Handle error state.

      if (widget.asModal) {
        return Navigator.pop(context);
      }

      unawaited(
        Navigator.of(context).pushReplacement(TagDetailPage.route(id: item.tag.id)),
      );
    };
  }
}
