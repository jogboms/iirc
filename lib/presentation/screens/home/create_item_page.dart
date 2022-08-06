import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iirc/core.dart';
import 'package:iirc/domain.dart';

import '../../utils/extensions.dart';
import '../../widgets/custom_app_bar.dart';
import '../tags/tag_detail_page.dart';
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
        description: '',
        date: widget.date,
        tag: widget.tag,
        type: ItemEntryType.create,
        onSaved: _onSubmit(context),
      ),
    );
  }

  ItemEntryValueSaved _onSubmit(BuildContext context) {
    return (WidgetRef ref, ItemEntryData data) async {
      try {
        // TODO: Handle loading state.
        await ref.read(itemProvider).create(CreateItemData(
              description: data.description,
              date: data.date,
              tag: data.tag.reference,
            ));

        if (widget.asModal) {
          return Navigator.pop(context);
        }

        unawaited(
          Navigator.of(context).pushReplacement(TagDetailPage.route(id: data.tag.id)),
        );
      } catch (error, stackTrace) {
        AppLog.e(error, stackTrace);
        // TODO: Handle error state.
      }
    };
  }
}
