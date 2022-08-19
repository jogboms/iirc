import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iirc/core.dart';
import 'package:iirc/domain.dart';

import '../../constants/app_routes.dart';
import '../../models.dart';
import '../../state.dart';
import '../../utils.dart';
import '../../widgets.dart';
import '../tags/tag_detail_page.dart';
import 'item_entry_form.dart';
import 'providers/item_provider.dart';

class CreateItemPage extends StatefulWidget {
  const CreateItemPage({super.key, required this.asModal, this.date, this.tag});

  static PageRoute<void> route({bool asModal = false, DateTime? date, TagViewModel? tag}) {
    return MaterialPageRoute<void>(
      builder: (_) => CreateItemPage(asModal: asModal, date: date, tag: tag),
      settings: const RouteSettings(name: AppRoutes.createItem),
    );
  }

  final bool asModal;
  final DateTime? date;
  final TagViewModel? tag;

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
      body: Consumer(
        builder: (BuildContext context, WidgetRef ref, _) => ItemEntryForm(
          analytics: ref.read(analyticsProvider),
          description: '',
          date: widget.date,
          tag: widget.tag,
          type: ItemEntryType.create,
          onSaved: _onSubmit(context),
        ),
      ),
    );
  }

  ItemEntryValueSaved _onSubmit(BuildContext context) {
    final AppSnackBar snackBar = context.snackBar;
    final L10n l10n = context.l10n;
    return (WidgetRef ref, ItemEntryData data) async {
      try {
        snackBar.loading();

        await ref.read(itemProvider).create(CreateItemData(
              description: data.description,
              date: data.date,
              tag: data.tag.reference,
            ));

        snackBar.success(l10n.successfulMessage);
        if (widget.asModal) {
          return Navigator.pop(context);
        }

        unawaited(
          Navigator.of(context).pushReplacement(TagDetailPage.route(id: data.tag.id)),
        );
      } catch (error, stackTrace) {
        AppLog.e(error, stackTrace);
        snackBar.error(l10n.genericErrorMessage);
      } finally {
        snackBar.hide();
      }
    };
  }
}
