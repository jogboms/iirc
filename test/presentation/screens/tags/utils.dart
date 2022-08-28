import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/presentation.dart';
import 'package:mocktail/mocktail.dart';

extension WidgetTesterExtensions on WidgetTester {
  Future<void> enterFields() async {
    await enterText(find.byKey(TagEntryFormState.titleFieldKey), 'title');
    await enterText(find.byKey(TagEntryFormState.descriptionFieldKey), 'description');
    state<ColorPickerState>(find.byKey(TagEntryFormState.colorFieldKey)).didChange(const Color(0xFFFFFFFF));
    await pump();

    await tap(find.byKey(TagEntryFormState.submitButtonKey));
    await pump();
  }
}

class MockTagProvider extends Mock implements TagProvider {}
