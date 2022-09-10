import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iirc/core.dart';
import 'package:iirc/domain.dart';

import '../../constants/app_routes.dart';
import '../../state.dart';
import '../../utils.dart';
import '../../widgets.dart';
import 'providers/tag_provider.dart';
import 'tag_detail_page.dart';
import 'tag_entry_form.dart';

class CreateTagPage extends StatelessWidget {
  const CreateTagPage({super.key, required this.asModal});

  static PageRoute<String> route({bool asModal = false}) {
    return MaterialPageRoute<String>(
      builder: (_) => CreateTagPage(asModal: asModal),
      settings: const RouteSettings(name: AppRoutes.createTag),
    );
  }

  final bool asModal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Text(context.l10n.createTagCaption),
      ),
      body: Consumer(
        builder: (BuildContext context, WidgetRef ref, _) => TagEntryForm(
          analytics: ref.read(analyticsProvider),
          initialValue: null,
          type: TagEntryType.create,
          onSaved: _onSubmit(context, ref),
        ),
      ),
    );
  }

  ValueChanged<TagEntryData> _onSubmit(BuildContext context, WidgetRef ref) {
    final AppSnackBar snackBar = context.snackBar;
    final L10n l10n = context.l10n;
    final NavigatorState navigator = Navigator.of(context);
    return (TagEntryData data) async {
      try {
        snackBar.loading();

        final String id = await ref.read(tagProvider).create(
              CreateTagData(
                title: data.title,
                description: data.description,
                color: data.color,
              ),
            );

        snackBar.success(l10n.successfulMessage);
        if (asModal) {
          return navigator.pop(id);
        }

        unawaited(navigator.pushReplacement(TagDetailPage.route(id: id)));
      } catch (error, stackTrace) {
        AppLog.e(error, stackTrace);
        snackBar.error(l10n.genericErrorMessage);
      } finally {
        snackBar.hide();
      }
    };
  }
}
