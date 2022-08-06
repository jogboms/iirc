import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iirc/core.dart';
import 'package:iirc/domain.dart';

import '../../utils/extensions.dart';
import '../../widgets/custom_app_bar.dart';
import 'providers/tag_provider.dart';
import 'tag_detail_page.dart';
import 'tag_entry_form.dart';

class CreateTagPage extends StatelessWidget {
  const CreateTagPage({super.key, required this.asModal});

  static PageRoute<String> route({bool asModal = false}) {
    return MaterialPageRoute<String>(builder: (_) => CreateTagPage(asModal: asModal));
  }

  final bool asModal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Text(context.l10n.createTagCaption),
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
      try {
        // TODO: Handle loading state.
        final String id = await ref.read(tagProvider).create(CreateTagData(
              title: data.title,
              description: data.description,
              color: data.color,
            ));

        if (asModal) {
          return Navigator.of(context).pop(id);
        }

        unawaited(
          Navigator.of(context).pushReplacement(TagDetailPage.route(id: id)),
        );
      } catch (error, stackTrace) {
        AppLog.e(error, stackTrace);
        // TODO: Handle error state.
      }
    };
  }
}
