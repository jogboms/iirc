import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iirc/core.dart';
import 'package:iirc/domain.dart';

import '../../constants/app_routes.dart';
import '../../state.dart';
import '../../utils.dart';
import '../../widgets.dart';
import 'providers/tag_provider.dart';
import 'tag_entry_form.dart';

class UpdateTagPage extends StatelessWidget {
  const UpdateTagPage({super.key, required this.tag});

  static PageRoute<void> route({required TagEntity tag}) {
    return MaterialPageRoute<void>(
      builder: (_) => UpdateTagPage(tag: tag),
      settings: const RouteSettings(name: AppRoutes.updateTag),
    );
  }

  final TagEntity tag;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Text(context.l10n.updateTagCaption),
      ),
      body: Consumer(
        builder: (BuildContext context, WidgetRef ref, _) => TagEntryForm(
          analytics: ref.read(analyticsProvider),
          initialValue: TagEntryData(
            title: tag.title,
            description: tag.description,
            color: tag.color,
          ),
          type: TagEntryType.update,
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

        await ref.read(tagProvider).update(
              UpdateTagData(
                id: tag.id,
                path: tag.path,
                title: data.title,
                description: data.description,
                color: data.color,
              ),
            );

        snackBar.success(l10n.successfulMessage);
        return navigator.pop();
      } catch (error, stackTrace) {
        AppLog.e(error, stackTrace);
        snackBar.error(l10n.genericErrorMessage);
      } finally {
        snackBar.hide();
      }
    };
  }
}
