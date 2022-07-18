import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iirc/core.dart';
import 'package:iirc/domain.dart';
import 'package:iirc/screens.dart';
import 'package:iirc/screens/tags/providers/tags_provider.dart';
import 'package:iirc/widgets.dart';
import 'package:intl/intl.dart';

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
  late final ValueNotifier<CreateItemData> dataNotifier = ValueNotifier<CreateItemData>(
    CreateItemData(description: '', date: widget.date ?? clock.now(), tag: widget.tag),
  );

  @override
  void dispose() {
    dataNotifier.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = context.theme;

    return Scaffold(
      appBar: CustomAppBar(
        title: Text(context.l10n.createItemCaption),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SizedBox(height: 12),
            if (widget.date == null) ...<Widget>[
              FormField<DateTime>(
                initialValue: dataNotifier.value.date,
                builder: (FormFieldState<DateTime> fieldState) {
                  final DateTime date = fieldState.value!;

                  return Row(
                    children: <Widget>[
                      Text(
                        DateFormat.yMMMEd().format(date),
                        style: theme.textTheme.bodyLarge,
                      ),
                      const SizedBox(width: 4),
                      TextButton(
                        onPressed: () async {
                          final DateTime? value = await showDatePicker(
                            context: context,
                            initialDate: date,
                            firstDate: DateTime(0),
                            lastDate: DateTime(clock.now().year + 1),
                          );
                          if (value != null) {
                            dataNotifier.update(date: value);
                            fieldState.didChange(value);
                          }
                        },
                        child: Text(context.l10n.selectItemDateCaption),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
            if (widget.tag == null) ...<Widget>[
              Consumer(
                builder: (BuildContext context, WidgetRef ref, Widget? child) {
                  final List<TagModel> tags = ref.watch(tagsStateProvider).value ?? <TagModel>[];

                  if (tags.isEmpty) {
                    return child!;
                  }

                  return DropdownButtonFormField<TagModel>(
                    value: dataNotifier.value.tag,
                    decoration: InputDecoration(hintText: context.l10n.selectItemTagCaption),
                    items: <DropdownMenuItem<TagModel>>[
                      for (final TagModel tag in tags)
                        DropdownMenuItem<TagModel>(
                          value: tag,
                          child: Row(
                            children: <Widget>[
                              TagColorBox(code: tag.color),
                              const SizedBox(width: 8),
                              Text(tag.title),
                            ],
                          ),
                        ),
                    ],
                    onChanged: (TagModel? tag) => dataNotifier.update(tag: tag),
                  );
                },
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).push(CreateTagPage.route(asModal: true)),
                    child: Text(context.l10n.createNewTagCaption),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            TextField(
              decoration: InputDecoration(label: Text(context.l10n.descriptionLabel)),
              maxLines: 4,
              onChanged: (String value) => dataNotifier.update(description: value),
            ),
            const SizedBox(height: 24),
            ValueListenableBuilder<CreateItemData>(
              valueListenable: dataNotifier,
              builder: (BuildContext context, CreateItemData value, Widget? child) => Consumer(
                builder: (BuildContext context, WidgetRef ref, _) => OutlinedButton(
                  onPressed: value.isValid ? () => _onSubmit(ref, value) : null,
                  child: child!,
                ),
              ),
              child: Text(context.l10n.submitCaption),
            ),
          ],
        ),
      ),
    );
  }

  void _onSubmit(WidgetRef ref, CreateItemData data) async {
    final ItemModel item = await ref.read(itemProvider).create(data);

    // TODO: Handle loading state.

    if (widget.asModal) {
      return Navigator.pop(context);
    }

    unawaited(
      Navigator.of(context).pushReplacement(ItemDetailPage.route(id: item.tag.id)),
    );
  }
}

extension on ValueNotifier<CreateItemData> {
  void update({String? description, DateTime? date, TagModel? tag}) =>
      value = value.copyWith(description: description, date: date, tag: tag);
}
