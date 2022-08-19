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

  @override
  bool? get stringify => true;
}

typedef ItemEntryValueSaved = void Function(WidgetRef ref, ItemEntryData data);

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
      date: DateUtils.dateOnly(widget.date ?? clock.now()),
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
    unawaited(widget.analytics.log(AnalyticsEvent.buttonClick('create tag: form')));
    final String? tagId = await Navigator.of(context).push<String>(CreateTagPage.route(asModal: true));
    if (tagId != null) {
      final TagViewModelList tags = read(tagsProvider).value ?? TagViewModelList.empty();
      dataNotifier.update(tag: tags.firstWhere((TagModel element) => element.id == tagId));
    }
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
                      onPressed: () => onCreateTag(context, ref.read),
                      icon: const Icon(Icons.tag),
                      label: Text(context.l10n.createNewTagCaption),
                    ),
                  );
                }

                return Row(
                  children: <Widget>[
                    Expanded(
                      child: DropdownButtonFormField<TagViewModel>(
                        value: dataNotifier.value.tag.isEmptyTag ? null : dataNotifier.value.tag,
                        decoration: InputDecoration(
                          hintText: context.l10n.selectItemTagCaption,
                        ),
                        items: <DropdownMenuItem<TagViewModel>>[
                          for (final TagViewModel tag in tags)
                            DropdownMenuItem<TagViewModel>(
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
                        onChanged: (TagViewModel? tag) => dataNotifier.update(tag: tag),
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
              builder: (BuildContext context, WidgetRef ref, _) => ElevatedButton(
                onPressed: value.isValid
                    ? () => widget
                      ..analytics.log(AnalyticsEvent.buttonClick('submit item'))
                      ..onSaved(ref, value)
                    : null,
                child: child,
              ),
            ),
            child: Text(context.l10n.submitCaption),
          ),
        ],
      ),
    );
  }
}

final TagViewModel _emptyTagModel = TagViewModel.fromTag(TagModel(
  id: 'EMPTY',
  color: 0xF,
  description: '',
  title: '',
  path: '',
  createdAt: DateTime(0),
  updatedAt: null,
));

extension on TagViewModel {
  bool get isEmptyTag => this == _emptyTagModel;
}

extension on ValueNotifier<ItemEntryData> {
  void update({String? description, DateTime? date, TagViewModel? tag}) =>
      value = value.copyWith(description: description, date: date, tag: tag);
}
