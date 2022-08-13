import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iirc/domain.dart';

import '../../models.dart';
import '../../state.dart';
import '../../widgets.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  static const Key dataViewKey = Key('dataViewKey');

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) => ref.watch(itemsProvider).when(
            data: (ItemViewModelList items) => _ItemsDataView(
              key: dataViewKey,
              items: items,
              analytics: ref.read(analyticsProvider),
            ),
            error: ErrorView.new,
            loading: () => child!,
          ),
      child: const LoadingView(),
    );
  }
}

class _ItemsDataView extends ConsumerStatefulWidget {
  const _ItemsDataView({super.key, required this.items, required this.analytics});

  final ItemViewModelList items;
  final Analytics analytics;

  @override
  ConsumerState<_ItemsDataView> createState() => _ItemsDataViewState();
}

class _ItemsDataViewState extends ConsumerState<_ItemsDataView> {
  final ItemCalendarViewController itemCalendarViewController = ItemCalendarViewController();

  @override
  void initState() {
    super.initState();

    itemCalendarViewController.addListener(() {
      ref.read(calendarStateProvider.notifier).state = itemCalendarViewController.selectedDate;
    });
  }

  @override
  void dispose() {
    itemCalendarViewController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        ItemCalendarViewGroup(
          primary: true,
          controller: itemCalendarViewController,
          items: widget.items,
          analytics: widget.analytics,
        ),
      ],
    );
  }
}
