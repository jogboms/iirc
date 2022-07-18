import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iirc/core.dart';
import 'package:iirc/domain.dart';
import 'package:iirc/screens.dart';
import 'package:iirc/widgets.dart';

import 'providers/tag_provider.dart';

class CreateTagPage extends StatefulWidget {
  const CreateTagPage({super.key});

  static PageRoute<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const CreateTagPage());
  }

  @override
  State<CreateTagPage> createState() => CreateTagPageState();
}

@visibleForTesting
class CreateTagPageState extends State<CreateTagPage> {
  final ValueNotifier<CreateTagData> dataNotifier = ValueNotifier<CreateTagData>(
    const CreateTagData(color: 0, title: '', description: ''),
  );

  @override
  void dispose() {
    dataNotifier.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Text(context.l10n.createTag),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(label: Text(context.l10n.titleLabel)),
              onChanged: (String value) => dataNotifier.update(title: value),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(label: Text(context.l10n.descriptionLabel)),
              maxLines: 4,
              onChanged: (String value) => dataNotifier.update(description: value),
            ),
            const SizedBox(height: 16),
            ValueListenableBuilder<CreateTagData>(
              valueListenable: dataNotifier,
              builder: (BuildContext context, CreateTagData value, _) => ColorPickerField(
                initialValue: Color(value.color),
                onChanged: (Color color) => dataNotifier.update(color: color.value),
              ),
            ),
            const SizedBox(height: 24),
            ValueListenableBuilder<CreateTagData>(
              valueListenable: dataNotifier,
              builder: (BuildContext context, CreateTagData value, Widget? child) => Consumer(
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

  void _onSubmit(WidgetRef ref, CreateTagData data) async {
    final TagModel tag = await ref.read(tagProvider).create(data);

    // TODO: Handle loading state.
    unawaited(
      Navigator.of(context).pushReplacement(ItemDetailPage.route(id: tag.id)),
    );
  }
}

extension on ValueNotifier<CreateTagData> {
  void update({String? title, String? description, int? color}) =>
      value = value.copyWith(title: title, description: description, color: color);
}
