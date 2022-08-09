import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../utils.dart';
import '../../widgets.dart';

enum TagEntryType { create, update }

class TagEntryData with EquatableMixin {
  const TagEntryData({
    required this.title,
    required this.description,
    required this.color,
  });

  final String title;
  final String description;
  final int color;

  TagEntryData copyWith({
    String? title,
    String? description,
    int? color,
  }) =>
      TagEntryData(
        title: title ?? this.title,
        description: description ?? this.description,
        color: color ?? this.color,
      );

  @override
  List<Object> get props => <Object>[title, description, color];

  bool get isValid => title.length > 3 && description.isNotEmpty && color != 0;

  @override
  bool? get stringify => true;
}

typedef TagEntryValueSaved = void Function(WidgetRef ref, TagEntryData data);

class TagEntryForm extends StatefulWidget {
  const TagEntryForm({
    super.key,
    required this.initialValue,
    required this.type,
    required this.onSaved,
  });

  final TagEntryData? initialValue;
  final TagEntryType type;
  final TagEntryValueSaved onSaved;

  @override
  State<TagEntryForm> createState() => TagEntryFormState();
}

@visibleForTesting
class TagEntryFormState extends State<TagEntryForm> {
  late final ValueNotifier<TagEntryData> dataNotifier = ValueNotifier<TagEntryData>(
    TagEntryData(
      title: widget.initialValue?.title ?? '',
      description: widget.initialValue?.description ?? '',
      color: widget.initialValue?.color ?? 0,
    ),
  );

  late final TextEditingController titleTextEditingController = TextEditingController(
    text: dataNotifier.value.title,
  );
  late final TextEditingController descriptionTextEditingController = TextEditingController(
    text: dataNotifier.value.description,
  );

  @override
  void dispose() {
    titleTextEditingController.dispose();
    descriptionTextEditingController.dispose();
    dataNotifier.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SizedBox(height: 12),
          TextField(
            controller: titleTextEditingController,
            autofocus: true,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              label: Text(context.l10n.titleLabel),
              alignLabelWithHint: true,
            ),
            onChanged: (String value) => dataNotifier.update(title: value.trim()),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: descriptionTextEditingController,
            decoration: InputDecoration(
              label: Text(context.l10n.descriptionLabel),
              alignLabelWithHint: true,
            ),
            maxLines: 4,
            onChanged: (String value) => dataNotifier.update(description: value.trim()),
          ),
          const SizedBox(height: 16),
          ValueListenableBuilder<TagEntryData>(
            valueListenable: dataNotifier,
            builder: (BuildContext context, TagEntryData value, _) => ColorPickerField(
              initialValue: Color(value.color),
              onChanged: (Color color) => dataNotifier.update(color: color.value),
            ),
          ),
          const SizedBox(height: 24),
          ValueListenableBuilder<TagEntryData>(
            valueListenable: dataNotifier,
            builder: (BuildContext context, TagEntryData value, Widget? child) => Consumer(
              builder: (BuildContext context, WidgetRef ref, _) => ElevatedButton(
                onPressed: value.isValid ? () => widget.onSaved(ref, value) : null,
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

extension on ValueNotifier<TagEntryData> {
  void update({String? title, String? description, int? color}) =>
      value = value.copyWith(title: title, description: description, color: color);
}
