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
  final TagModel tag;

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
  List<Object> get props => <Object>[description, date, tag];

  bool get isValid => description.isNotEmpty && !tag.isEmptyTag;

  @override
  bool? get stringify => true;
}

typedef ItemEntryValueSaved = void Function(WidgetRef ref, ItemEntryData data);

class ItemEntryForm extends StatefulWidget {
  const ItemEntryForm({
    super.key,
    required this.description,
    required this.date,
    required this.tag,
    required this.type,
    required this.onSaved,
  });

  final String? description;
  final DateTime? date;
  final TagModel? tag;
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
      description: widget.description ?? '',
      date: widget.date ?? clock.now(),
      tag: widget.tag ?? _emptyTagModel,
    ),
  );

  late final TextEditingController descriptionTextEditingController = TextEditingController(
    text: dataNotifier.value.description,
  );

  bool get hasInitialDate => widget.date != null;

  bool get hasInitialTag => widget.tag != null;

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

  void onCreateTag(BuildContext context, Reader read) async {
    final String? tagId = await Navigator.of(context).push<String>(CreateTagPage.route(asModal: true));
    if (tagId != null) {
      final TagModelList tags = read(tagsProvider).value ?? TagModelList.empty();
      dataNotifier.update(tag: tags.firstWhere((TagModel element) => element.id == tagId));
    }
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
          if (!hasInitialDate || widget.type == ItemEntryType.update) ...<Widget>[
            FormField<DateTime>(
              initialValue: dataNotifier.value.date,
              builder: (FormFieldState<DateTime> fieldState) {
                final DateTime date = fieldState.value!;

                return Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        DateFormat.yMMMEd().format(date),
                        style: theme.textTheme.bodyLarge,
                      ),
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
          if (!hasInitialTag || widget.type == ItemEntryType.update) ...<Widget>[
            Consumer(
              builder: (BuildContext context, WidgetRef ref, Widget? child) {
                final List<TagModel> tags = ref.watch(tagsProvider).value ?? <TagModel>[];

                if (tags.isEmpty) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () => onCreateTag(context, ref.read),
                      icon: const Icon(Icons.tag),
                      label: Text(context.l10n.createNewTagCaption),
                    ),
                  );
                }

                return Row(
                  children: <Widget>[
                    Expanded(
                      child: DropdownButtonFormField<TagModel>(
                        value: dataNotifier.value.tag.isEmptyTag ? null : dataNotifier.value.tag,
                        decoration: InputDecoration(
                          hintText: context.l10n.selectItemTagCaption,
                        ),
                        items: <DropdownMenuItem<TagModel>>[
                          for (final TagModel tag in tags)
                            DropdownMenuItem<TagModel>(
                              key: Key(tag.id),
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
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => onCreateTag(context, ref.read),
                      icon: const Icon(Icons.add),
                    ),
                  ],
                );
              },
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

final TagModel _emptyTagModel = TagModel(
  id: 'EMPTY',
  color: 0xF,
  description: '',
  title: '',
  path: '',
  createdAt: DateTime(0),
  updatedAt: null,
);

extension on TagModel {
  bool get isEmptyTag => this == _emptyTagModel;
}

extension on ValueNotifier<ItemEntryData> {
  void update({String? description, DateTime? date, TagModel? tag}) =>
      value = value.copyWith(description: description, date: date, tag: tag);
}
