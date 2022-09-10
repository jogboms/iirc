import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/data.dart';
import 'package:iirc/domain.dart';
import 'package:iirc/presentation.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod/riverpod.dart';

import '../../../mocks.dart';
import '../../../utils.dart';

void main() {
  final TagViewModel dummyTagViewModel = TagModel(
    id: '1',
    color: 0xF,
    description: 'description',
    title: 'title',
    path: 'path',
    createdAt: DateTime(0),
    updatedAt: null,
  ).asViewModel;
  final TagViewModelList dummyTagsList = <TagViewModel>[
    dummyTagViewModel,
    ...TagViewModelList.generate(3, (_) => TagsMockImpl.generateTag().asViewModel),
  ];

  group('ItemEntryData', () {
    test('should only be valid under right conditions', () {
      final Map<ItemEntryData, bool> cases = <ItemEntryData, bool>{
        ItemEntryData(description: '', date: DateTime(0), tag: emptyTagModel): false,
        ItemEntryData(description: 'des', date: DateTime(0), tag: emptyTagModel): false,
        ItemEntryData(description: 'description', date: DateTime(0), tag: emptyTagModel): false,
        ItemEntryData(description: 'description', date: DateTime(0), tag: emptyTagModel): false,
        ItemEntryData(description: 'description', date: DateTime(0), tag: dummyTagViewModel): true,
      };
      for (final MapEntry<ItemEntryData, bool> entry in cases.entries) {
        expect(entry.key.isValid, entry.value);
      }
    });

    test('should copy to new instance', () {
      expect(
        ItemEntryData(description: '', date: DateTime(0), tag: emptyTagModel).copyWith(
          description: 'description',
          date: DateTime(1),
          tag: dummyTagViewModel,
        ),
        ItemEntryData(
          description: 'description',
          date: DateTime(1),
          tag: dummyTagViewModel,
        ),
      );
    });

    test('should be equal when equal', () {
      expect(
        ItemEntryData(
          description: 'description',
          date: DateTime(0),
          tag: dummyTagViewModel,
        ),
        ItemEntryData(
          description: 'description',
          date: DateTime(0),
          tag: dummyTagViewModel,
        ),
      );
    });

    test('should serialize to string', () {
      expect(
        ItemEntryData(
          description: 'description',
          date: DateTime(0),
          tag: dummyTagViewModel,
        ).toString(),
        'ItemEntryData(description, 0000-01-01 00:00:00.000, TagViewModel(1, path, title, description, 15, 0000-01-01 00:00:00.000, null))',
      );
    });
  });

  group('ItemEntryForm', () {
    final Finder itemEntryForm = find.byType(ItemEntryForm);
    final NavigatorObserver navigatorObserver = MockNavigatorObserver();
    const Analytics analytics = NoopAnalytics();

    setUpAll(() {
      registerFallbackValue(FakeRoute());
    });

    tearDown(() {
      reset(navigatorObserver);
    });

    testWidgets('smoke test', (WidgetTester tester) async {
      await tester.pumpWidget(
        createApp(
          home: ItemEntryForm(
            description: 'description',
            date: DateTime(0),
            tag: dummyTagViewModel,
            type: ItemEntryType.create,
            analytics: analytics,
            onSaved: (_) {},
          ),
        ),
      );

      await tester.pump();

      expect(itemEntryForm, findsOneWidget);
    });

    testWidgets('should assign initial values', (WidgetTester tester) async {
      final ItemEntryData initialValue = ItemEntryData(
        description: 'description',
        date: DateTime(0),
        tag: dummyTagViewModel,
      );
      await tester.pumpWidget(
        createApp(
          home: ItemEntryForm(
            description: initialValue.description,
            date: initialValue.date,
            tag: initialValue.tag,
            type: ItemEntryType.update,
            analytics: analytics,
            onSaved: (_) {},
          ),
          overrides: <Override>[
            tagsProvider.overrideWithValue(AsyncData<TagViewModelList>(dummyTagsList)),
          ],
        ),
      );

      await tester.pump();

      expect(tester.textFieldControllerByKey(ItemEntryFormState.descriptionFieldKey)?.text, initialValue.description);
      expect(
        tester.state<FormFieldState<String>>(find.byKey(ItemEntryFormState.tagsFieldKey)).value,
        initialValue.tag.id,
      );
      expect(
        tester.state<DatePickerState>(find.byKey(ItemEntryFormState.dateFieldKey)).value,
        initialValue.date,
      );
    });

    testWidgets('should hide date picker when initial date is given and in create mode', (WidgetTester tester) async {
      await tester.pumpWidget(
        createApp(
          home: ItemEntryForm(
            description: null,
            date: DateTime(0),
            tag: null,
            type: ItemEntryType.create,
            analytics: analytics,
            onSaved: (_) {},
          ),
        ),
      );

      await tester.pump();

      expect(find.byKey(ItemEntryFormState.dateFieldKey), findsNothing);
    });

    testWidgets('should hide tag picker when initial tag is given and in create mode', (WidgetTester tester) async {
      await tester.pumpWidget(
        createApp(
          home: ItemEntryForm(
            description: null,
            date: null,
            tag: dummyTagViewModel,
            type: ItemEntryType.create,
            analytics: analytics,
            onSaved: (_) {},
          ),
        ),
      );

      await tester.pump();

      expect(find.byKey(ItemEntryFormState.tagsFieldKey), findsNothing);
    });

    testWidgets('should show create tag button when total tags is empty', (WidgetTester tester) async {
      await tester.pumpWidget(
        createApp(
          home: ItemEntryForm(
            description: null,
            date: null,
            tag: dummyTagViewModel,
            type: ItemEntryType.update,
            analytics: analytics,
            onSaved: (_) {},
          ),
        ),
      );

      await tester.pump();

      expect(find.byKey(ItemEntryFormState.tagsFieldKey), findsNothing);
      expect(find.byKey(ItemEntryFormState.createTagButtonKey), findsOneWidget);
    });

    testWidgets('should navigate to create tag when total tags is empty', (WidgetTester tester) async {
      await tester.pumpWidget(
        createApp(
          observers: <NavigatorObserver>[navigatorObserver],
          home: ItemEntryForm(
            description: null,
            date: null,
            tag: null,
            type: ItemEntryType.update,
            analytics: analytics,
            onSaved: (_) {},
          ),
          overrides: <Override>[
            tagsProvider.overrideWithValue(AsyncData<TagViewModelList>(TagViewModelList.empty())),
          ],
        ),
      );

      await tester.pump();

      await tester.tap(find.byKey(ItemEntryFormState.createTagButtonKey));
      await tester.verifyPushNavigation<CreateTagPage>(navigatorObserver);

      await tester.pageBack();
      await tester.pumpAndSettle();
    });

    testWidgets('should navigate to create tag when total tags are available', (WidgetTester tester) async {
      await tester.pumpWidget(
        createApp(
          observers: <NavigatorObserver>[navigatorObserver],
          home: ItemEntryForm(
            description: null,
            date: null,
            tag: null,
            type: ItemEntryType.update,
            analytics: analytics,
            onSaved: (_) {},
          ),
          overrides: <Override>[
            tagsProvider.overrideWithValue(AsyncData<TagViewModelList>(dummyTagsList)),
          ],
        ),
      );

      await tester.pump();

      await tester.tap(find.byKey(ItemEntryFormState.createTagButtonKey));
      await tester.verifyPushNavigation<CreateTagPage>(navigatorObserver);

      await tester.pageBack();
      await tester.pumpAndSettle();
    });

    testWidgets('should show single tag when total tags are exactly 1', (WidgetTester tester) async {
      await tester.pumpWidget(
        createApp(
          home: ItemEntryForm(
            description: null,
            date: null,
            tag: dummyTagViewModel,
            type: ItemEntryType.update,
            analytics: analytics,
            onSaved: (_) {},
          ),
          overrides: <Override>[
            tagsProvider.overrideWithValue(AsyncData<TagViewModelList>(dummyTagsList.sublist(0, 1))),
          ],
        ),
      );

      await tester.pump();

      expect(find.byKey(Key(dummyTagsList.first.id)), findsOneWidget);
    });

    testWidgets('should assign default initial values', (WidgetTester tester) async {
      await withClock(Clock.fixed(DateTime(0)), () async {
        await tester.pumpWidget(
          createApp(
            home: ItemEntryForm(
              description: null,
              date: null,
              tag: null,
              type: ItemEntryType.update,
              analytics: analytics,
              onSaved: (_) {},
            ),
            overrides: <Override>[
              tagsProvider.overrideWithValue(AsyncData<TagViewModelList>(dummyTagsList)),
            ],
          ),
        );

        await tester.pump();
      });

      expect(tester.textFieldControllerByKey(ItemEntryFormState.descriptionFieldKey)?.text, '');
      expect(tester.state<FormFieldState<String>>(find.byKey(ItemEntryFormState.tagsFieldKey)).value, null);
      expect(tester.state<DatePickerState>(find.byKey(ItemEntryFormState.dateFieldKey)).value, DateTime(0));
    });

    testWidgets('should enable submit button only when valid', (WidgetTester tester) async {
      final MockValueChangedCallback<ItemEntryData> onSubmit = MockValueChangedCallback<ItemEntryData>();

      await tester.pumpWidget(
        createApp(
          home: ItemEntryForm(
            description: null,
            date: null,
            tag: null,
            type: ItemEntryType.update,
            analytics: analytics,
            onSaved: onSubmit,
          ),
          overrides: <Override>[
            tagsProvider.overrideWithValue(AsyncData<TagViewModelList>(dummyTagsList)),
          ],
        ),
      );

      await tester.pump();

      final Finder submitButton = find.byKey(ItemEntryFormState.submitButtonKey);
      await tester.tap(submitButton);

      verifyZeroInteractions(onSubmit);

      await tester.enterText(find.byKey(ItemEntryFormState.descriptionFieldKey), 'description');
      await tester.pump();

      verifyZeroInteractions(onSubmit);

      await tester.tap(submitButton);

      await tester.tap(find.byKey(ItemEntryFormState.tagsFieldKey));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining(dummyTagsList.first.title).last);
      await tester.pumpAndSettle();

      verifyZeroInteractions(onSubmit);

      tester.state<DatePickerState>(find.byKey(ItemEntryFormState.dateFieldKey)).didChange(DateTime(1));
      await tester.pump();

      await tester.tap(submitButton);

      verify(
        () => onSubmit(
          ItemEntryData(
            description: 'description',
            date: DateTime(1),
            tag: dummyTagViewModel,
          ),
        ),
      ).called(1);
    });
  });
}

extension on WidgetTester {
  TextEditingController? textFieldControllerByKey(Key key) => widget<TextField>(find.byKey(key)).controller;
}
