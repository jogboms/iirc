import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/presentation.dart';
import 'package:mocktail/mocktail.dart';

extension WidgetTesterExtensions on WidgetTester {
  Future<void> enterFields(TagViewModel tag) async {
    await enterText(find.byKey(ItemEntryFormState.descriptionFieldKey), 'description');

    await tap(find.byKey(ItemEntryFormState.tagsFieldKey));
    await pumpAndSettle();
    await tap(find.textContaining(tag.title).last);
    await pumpAndSettle();

    state<DatePickerState>(find.byKey(ItemEntryFormState.dateFieldKey)).didChange(DateTime(1));
    await pump();

    await tap(find.byKey(TagEntryFormState.submitButtonKey));
    await pump();
  }
}

class MockItemProvider extends Mock implements ItemProvider {}
