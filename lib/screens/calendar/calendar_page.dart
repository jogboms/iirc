import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iirc/core.dart';
import 'package:iirc/data.dart';
import 'package:iirc/state.dart';
import 'package:iirc/widgets.dart';

import '../widgets/item_calendar_list_view.dart';
import '../widgets/item_calendar_view.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  static const Key dataViewKey = Key('dataViewKey');

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.theme.brightness == Brightness.light ? Colors.grey.shade200 : Colors.grey.shade400,
      child: Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) => ref.watch(itemsProvider).when(
              data: (ItemViewModelList items) => _ItemsDataView(
                key: dataViewKey,
                items: items,
              ),
              error: ErrorView.new,
              loading: () => child!,
            ),
        child: const LoadingView(),
      ),
    );
  }
}

class _ItemsDataView extends ConsumerStatefulWidget {
  const _ItemsDataView({super.key, required this.items});

  final ItemViewModelList items;

  @override
  ConsumerState<_ItemsDataView> createState() => _ItemsDataViewState();
}

class _ItemsDataViewState extends ConsumerState<_ItemsDataView> {
  final ItemCalendarViewController itemCalendarViewController = ItemCalendarViewController();

  @override
  void initState() {
    super.initState();

    itemCalendarViewController.addListener(() {
      ref.read(calendarStateProvider.notifier).state = itemCalendarViewController.value;
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
        ItemCalendarView(
          controller: itemCalendarViewController,
          items: widget.items,
          primary: true,
        ),
        ItemCalendarListView(
          controller: itemCalendarViewController,
        ),
      ],
    );
  }
}
