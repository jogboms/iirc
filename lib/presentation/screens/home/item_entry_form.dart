import 'package:clock/clock.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iirc/domain.dart';
import 'package:intl/intl.dart';

import '../../state/tags_provider.dart';
import '../../theme/extensions.dart';
import '../../utils/extensions.dart';
import '../../widgets/tag_color_box.dart';
import '../tags/create_tag_page.dart';

enum ItemEntryType { create, update }

class ItemEntryData with EquatableMixin {
  const ItemEntryData({
    required this.description,
    required this.date,
    required this.tag,
  });

  final String description;
  final DateTime date;
  final TagModel? tag; // TODO: remove nullability

  ItemEntryData copyWith({
    String? description,
    DateTime? date,
    TagModel? tag,
  }) =>
      ItemEntryData(
        description: description ?? this.description,
        date: date ?? this.date,
        tag: tag ?? this.tag,
      );

  @override
  List<Object?> get props => <Object?>[description, date, tag];

  bool get isValid => description.isNotEmpty && tag != null;

  @override
  bool? get stringify => true;
}

typedef ItemEntryValueSaved = void Function(WidgetRef ref, ItemEntryData data);

class ItemEntryForm extends StatefulWidget {
  const ItemEntryForm({
    super.key,
    required this.initialValue,
    required this.type,
    required this.onSaved,
  });

  final ItemEntryData? initialValue;
  final ItemEntryType type;
  final ItemEntryValueSaved onSaved;

  @override
  State<ItemEntryForm> createState() => ItemEntryFormState();
}

@visibleForTesting
class ItemEntryFormState extends State<ItemEntryForm> {
  late final FocusNode descriptionFocusNode = FocusNode(debugLabel: 'description');

  late final ValueNotifier<ItemEntryData> dataNotifier = ValueNotifier<ItemEntryData>(
    ItemEntryData(
      description: widget.initialValue?.description ?? '',
      date: widget.initialValue?.date ?? clock.now(),
      tag: widget.initialValue?.tag,
    ),
  );

  late final TextEditingController descriptionTextEditingController = TextEditingController(
    text: dataNotifier.value.description,
  );

  bool get hasInitialDate => widget.initialValue?.date != null;

  bool get hasInitialTag => widget.initialValue?.tag != null;

  @override
  void initState() {
    if (hasInitialDate && hasInitialTag) {
      descriptionFocusNode.requestFocus();
    }

    super.initState();
  }

  @override
  void dispose() {
    descriptionFocusNode.dispose();
    descriptionTextEditingController.dispose();
    dataNotifier.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = context.theme;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SizedBox(height: 12),
          if (!hasInitialDate) ...<Widget>[
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
          if (!hasInitialTag) ...<Widget>[
            Consumer(
              builder: (BuildContext context, WidgetRef ref, Widget? child) {
                final List<TagModel> tags = ref.watch(tagsProvider).value ?? <TagModel>[];

                if (tags.isEmpty) {
                  return child!;
                }

                return DropdownButtonFormField<TagModel>(
                  value: dataNotifier.value.tag,
                  decoration: InputDecoration(
                    hintText: context.l10n.selectItemTagCaption,
                    alignLabelWithHint: true,
                  ),
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
            focusNode: descriptionFocusNode,
            controller: descriptionTextEditingController,
            decoration: InputDecoration(
              label: Text(context.l10n.descriptionLabel),
              alignLabelWithHint: true,
            ),
            maxLines: 4,
            onChanged: (String value) => dataNotifier.update(description: value.trim()),
          ),
          const SizedBox(height: 24),
          ValueListenableBuilder<ItemEntryData>(
            valueListenable: dataNotifier,
            builder: (BuildContext context, ItemEntryData value, Widget? child) => Consumer(
              builder: (BuildContext context, WidgetRef ref, _) => OutlinedButton(
                onPressed: value.isValid ? () => widget.onSaved(ref, value) : null,
                child: child!,
              ),
            ),
            child: Text(context.l10n.submitCaption),
          ),
        ],
      ),
    );
  }
}

extension on ValueNotifier<ItemEntryData> {
  void update({String? description, DateTime? date, TagModel? tag}) =>
      value = value.copyWith(description: description, date: date, tag: tag);
}
