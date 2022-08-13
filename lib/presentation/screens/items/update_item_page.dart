import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iirc/core.dart';
import 'package:iirc/domain.dart';

import '../../constants/app_routes.dart';
import '../../models.dart';
import '../../state.dart';
import '../../utils.dart';
import '../../widgets.dart';
import 'item_entry_form.dart';
import 'providers/item_provider.dart';

class UpdateItemPage extends StatefulWidget {
  const UpdateItemPage({super.key, required this.item});

  static PageRoute<void> route({required ItemViewModel item}) {
    return MaterialPageRoute<void>(
      builder: (_) => UpdateItemPage(item: item),
      settings: const RouteSettings(name: AppRoutes.updateItem),
    );
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
      body: Consumer(
        builder: (BuildContext context, WidgetRef ref, _) => ItemEntryForm(
          analytics: ref.read(analyticsProvider),
          description: widget.item.description,
          date: widget.item.date,
          tag: widget.item.tag,
          type: ItemEntryType.update,
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

        await ref.read(itemProvider).update(UpdateItemData(
              id: widget.item.id,
              path: widget.item.path,
              description: data.description,
              date: data.date,
              tag: data.tag.reference,
            ));

        snackBar.success(l10n.successfulMessage);
        return Navigator.pop(context);
      } catch (error, stackTrace) {
        AppLog.e(error, stackTrace);
        snackBar.error(l10n.genericErrorMessage);
      } finally {
        snackBar.hide();
      }
    };
  }
}
