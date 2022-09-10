import 'dart:async';

import 'package:clock/clock.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iirc/domain.dart';

import '../../models.dart';
import '../../state.dart';
import '../../utils.dart';
import '../../widgets.dart';
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
  final TagViewModel tag;

  ItemEntryData copyWith({
    String? description,
    DateTime? date,
    TagViewModel? tag,
  }) =>
      ItemEntryData(
        description: description ?? this.description,
        date: date ?? this.date,
        tag: tag ?? this.tag,
      );

  @override
  List<Object> get props => <Object>[description, date, tag];

  bool get isValid => description.length > 2 && !tag.isEmptyTag;
}

class ItemEntryForm extends StatefulWidget {
  const ItemEntryForm({
    super.key,
    required this.analytics,
    required this.description,
    required this.date,
    required this.tag,
    required this.type,
    required this.onSaved,
  });

  final Analytics analytics;
  final String? description;
  final DateTime? date;
  final TagViewModel? tag;
  final ItemEntryType type;
  final ValueChanged<ItemEntryData> onSaved;

  @override
  State<ItemEntryForm> createState() => ItemEntryFormState();
}

@visibleForTesting
class ItemEntryFormState extends State<ItemEntryForm> {
  static const Key descriptionFieldKey = Key('descriptionFieldKey');
  static const Key dateFieldKey = Key('dateFieldKey');
  static const Key createTagButtonKey = Key('createTagButtonKey');
  static const Key submitButtonKey = Key('submitButtonKey');
  static final GlobalKey<FormFieldState<String>> tagsFieldKey = GlobalKey(debugLabel: 'tagsFieldKey');

  late final FocusNode descriptionFocusNode = FocusNode(debugLabel: 'description');

  late final ValueNotifier<ItemEntryData> dataNotifier = ValueNotifier<ItemEntryData>(
    ItemEntryData(
      description: widget.description ?? '',
      date: DateUtils.dateOnly(widget.date ?? clock.now()),
      tag: widget.tag ?? emptyTagModel,
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
    unawaited(widget.analytics.log(AnalyticsEvent.buttonClick('create tag: form')));
    final String? tagId = await Navigator.of(context).push<String>(CreateTagPage.route(asModal: true));
    tagsFieldKey.currentState?.didChange(tagId);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SizedBox(height: 12),
          if (!hasInitialDate || widget.type == ItemEntryType.update) ...<Widget>[
            DatePickerField(
              key: dateFieldKey,
              initialValue: dataNotifier.value.date,
              onChanged: (DateTime value) => dataNotifier.update(date: value),
            ),
            const SizedBox(height: 12),
          ],
          if (!hasInitialTag || widget.type == ItemEntryType.update) ...<Widget>[
            Consumer(
              builder: (BuildContext context, WidgetRef ref, Widget? child) {
                final TagViewModelList tags = ref.watch(tagsProvider).value ?? TagViewModelList.empty();

                if (tags.isEmpty) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      key: createTagButtonKey,
                      onPressed: () => onCreateTag(context, ref.read),
                      icon: const Icon(Icons.tag),
                      label: Text(context.l10n.createNewTagCaption),
                    ),
                  );
                }

                return Row(
                  children: <Widget>[
                    Expanded(
                      child: tags.length == 1
                          ? Builder(
                              builder: (_) {
                                final TagViewModel tag = tags.first;
                                return _TagItem(key: Key(tag.id), tag: tags.first);
                              },
                            )
                          : DropdownButtonFormField<String>(
                              key: tagsFieldKey,
                              value: dataNotifier.value.tag.isEmptyTag ? null : dataNotifier.value.tag.id,
                              decoration: InputDecoration(
                                hintText: context.l10n.selectItemTagCaption,
                              ),
                              items: <DropdownMenuItem<String>>[
                                for (final TagViewModel tag in tags)
                                  DropdownMenuItem<String>(
                                    key: Key(tag.id),
                                    value: tag.id,
                                    child: _TagItem(tag: tag),
                                  ),
                              ],
                              onChanged: (String? id) {
                                if (id != null) {
                                  dataNotifier.update(tag: tags.firstWhere((TagViewModel element) => element.id == id));
                                }
                              },
                            ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      key: createTagButtonKey,
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
            key: descriptionFieldKey,
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
            builder: (BuildContext context, ItemEntryData value, Widget? child) => ElevatedButton(
              key: submitButtonKey,
              onPressed: value.isValid
                  ? () => widget
                    ..analytics.log(AnalyticsEvent.buttonClick('submit item'))
                    ..onSaved(value)
                  : null,
              child: child,
            ),
            child: Text(context.l10n.submitCaption),
          ),
        ],
      ),
    );
  }
}

class _TagItem extends StatelessWidget {
  const _TagItem({super.key, required this.tag});

  final TagViewModel tag;

  @override
  Widget build(BuildContext context) => Row(
        children: <Widget>[
          TagColorBox(code: tag.color),
          const SizedBox(width: 8),
          Text(tag.title),
        ],
      );
}

@visibleForTesting
final TagViewModel emptyTagModel = TagViewModel.fromTag(
  TagModel(
    id: 'EMPTY',
    color: 0xF,
    description: '',
    title: '',
    path: '',
    createdAt: DateTime(0),
    updatedAt: null,
  ),
);

extension on TagViewModel {
  bool get isEmptyTag => this == emptyTagModel;
}

extension on ValueNotifier<ItemEntryData> {
  void update({String? description, DateTime? date, TagViewModel? tag}) =>
      value = value.copyWith(description: description, date: date, tag: tag);
}
