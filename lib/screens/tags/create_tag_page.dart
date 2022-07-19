import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iirc/core.dart';
import 'package:iirc/domain.dart';
import 'package:iirc/screens.dart';
import 'package:iirc/widgets.dart';

import 'providers/tag_provider.dart';
import 'tag_entry_form.dart';

class CreateTagPage extends StatelessWidget {
  const CreateTagPage({super.key, required this.asModal});

  static PageRoute<void> route({bool asModal = false}) {
    return MaterialPageRoute<void>(builder: (_) => CreateTagPage(asModal: asModal));
  }

  final bool asModal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Text(context.l10n.createTag),
      ),
      body: TagEntryForm(
        initialValue: null,
        type: TagEntryType.create,
        onSaved: _onSubmit(context),
      ),
    );
  }

  TagEntryValueSaved _onSubmit(BuildContext context) {
    return (WidgetRef ref, TagEntryData data) async {
      final TagModel tag = await ref.read(tagProvider).create(CreateTagData(
            title: data.title,
            description: data.description,
            color: data.color,
          ));

      // TODO: Handle loading state.
      // TODO: Handle error state.

      if (asModal) {
        return Navigator.pop(context);
      }

      unawaited(
        Navigator.of(context).pushReplacement(ItemDetailPage.route(id: tag.id)),
      );
    };
  }
}
