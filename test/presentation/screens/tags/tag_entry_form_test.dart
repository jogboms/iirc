import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/domain.dart';
import 'package:iirc/presentation.dart';
import 'package:mocktail/mocktail.dart';

import '../../../mocks.dart';
import '../../../utils.dart';

void main() {
  group('TagEntryData', () {
    test('should only be valid under right conditions', () {
      final Map<TagEntryData, bool> cases = <TagEntryData, bool>{
        const TagEntryData(title: '', description: 'description', color: 0xF): false,
        const TagEntryData(title: 'tit', description: 'description', color: 0xF): false,
        const TagEntryData(title: 'title', description: '', color: 0xF): false,
        const TagEntryData(title: 'title', description: 'description', color: 0): false,
        const TagEntryData(title: 'title', description: 'description', color: 0xF): true,
      };
      for (final MapEntry<TagEntryData, bool> entry in cases.entries) {
        expect(entry.key.isValid, entry.value);
      }
    });

    test('should copy to new instance', () {
      expect(
        TagEntryData(title: nonconst(''), description: '', color: 0).copyWith(
          title: 'title',
          description: 'description',
          color: 0xF,
        ),
        TagEntryData(
          title: nonconst('title'),
          description: 'description',
          color: 0xF,
        ),
      );
    });

    test('should be equal when equal', () {
      expect(
        TagEntryData(
          title: nonconst('title'),
          description: 'description',
          color: 0xF,
        ),
        TagEntryData(
          title: nonconst('title'),
          description: 'description',
          color: 0xF,
        ),
      );
    });

    test('should serialize to string', () {
      expect(
        TagEntryData(
          title: nonconst('title'),
          description: 'description',
          color: 0xF,
        ).toString(),
        'TagEntryData(title, description, 15)',
      );
    });
  });

  group('TagEntryForm', () {
    final Finder tagEntryForm = find.byType(TagEntryForm);
    const Analytics analytics = NoopAnalytics();

    testWidgets('smoke test', (WidgetTester tester) async {
      await tester.pumpWidget(createApp(
        home: TagEntryForm(
          initialValue: TagEntryData(
            title: nonconst('title'),
            description: 'description',
            color: 0xF,
          ),
          type: TagEntryType.create,
          analytics: analytics,
          onSaved: (_) {},
        ),
      ));

      await tester.pump();

      expect(tagEntryForm, findsOneWidget);
    });

    testWidgets('should assign initial values', (WidgetTester tester) async {
      final TagEntryData initialValue = TagEntryData(
        title: nonconst('title'),
        description: 'description',
        color: 0xF,
      );
      await tester.pumpWidget(createApp(
        home: TagEntryForm(
          initialValue: initialValue,
          type: TagEntryType.create,
          analytics: analytics,
          onSaved: (_) {},
        ),
      ));

      await tester.pump();

      expect(tester.textFieldControllerByKey(TagEntryFormState.titleFieldKey)?.text, initialValue.title);
      expect(tester.textFieldControllerByKey(TagEntryFormState.descriptionFieldKey)?.text, initialValue.description);
      expect(
        tester.state<ColorPickerState>(find.byKey(TagEntryFormState.colorFieldKey)).value?.value,
        initialValue.color,
      );
    });

    testWidgets('should assign default initial values', (WidgetTester tester) async {
      await tester.pumpWidget(createApp(
        home: TagEntryForm(
          initialValue: null,
          type: TagEntryType.create,
          analytics: analytics,
          onSaved: (_) {},
        ),
      ));

      await tester.pump();

      expect(tester.textFieldControllerByKey(TagEntryFormState.titleFieldKey)?.text, '');
      expect(tester.textFieldControllerByKey(TagEntryFormState.descriptionFieldKey)?.text, '');
      expect(tester.state<ColorPickerState>(find.byKey(TagEntryFormState.colorFieldKey)).value?.value, 0);
    });

    testWidgets('should enable submit button only when valid', (WidgetTester tester) async {
      final MockValueChangedCallback<TagEntryData> onSubmit = MockValueChangedCallback<TagEntryData>();

      await tester.pumpWidget(createApp(
        home: TagEntryForm(
          initialValue: null,
          type: TagEntryType.create,
          analytics: analytics,
          onSaved: onSubmit,
        ),
      ));

      await tester.pump();

      final Finder submitButton = find.byKey(TagEntryFormState.submitButtonKey);
      await tester.tap(submitButton);

      verifyZeroInteractions(onSubmit);

      await tester.enterText(find.byKey(TagEntryFormState.titleFieldKey), 'title');
      await tester.pump();

      verifyZeroInteractions(onSubmit);

      await tester.tap(submitButton);

      await tester.enterText(find.byKey(TagEntryFormState.descriptionFieldKey), 'description');
      await tester.pump();

      verifyZeroInteractions(onSubmit);

      tester.state<ColorPickerState>(find.byKey(TagEntryFormState.colorFieldKey)).didChange(const Color(0xFFFFFFFF));
      await tester.pump();

      await tester.tap(submitButton);

      verify(
        () => onSubmit(
          TagEntryData(
            title: nonconst('title'),
            description: 'description',
            color: 0xFFFFFFFF,
          ),
        ),
      ).called(1);
    });
  });
}

extension on WidgetTester {
  TextEditingController? textFieldControllerByKey(Key key) => widget<TextField>(find.byKey(key)).controller;
}
