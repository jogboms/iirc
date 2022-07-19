import 'dart:collection';

import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iirc/core.dart';
import 'package:iirc/data.dart';
import 'package:iirc/domain.dart';
import 'package:iirc/widgets.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import 'create_item_page.dart';
import 'item_list_tile.dart';
import 'providers/selected_items_provider.dart';

final DateTime kToday = clock.now();

@visibleForTesting
class ItemDetailPageController with ChangeNotifier {
  DateTime? get date => _date;
  DateTime? _date;

  set date(DateTime? date) {
    if (this.date != date) {
      _date = date;
      notifyListeners();
    }
  }

  TagModel? get tag => _tag;
  TagModel? _tag;

  set tag(TagModel? tag) {
    if (this.tag != tag) {
      _tag = tag;
      notifyListeners();
    }
  }
}

class ItemDetailPage extends StatefulWidget {
  const ItemDetailPage({super.key, required this.id});

  final String id;

  static PageRoute<void> route({required String id}) {
    return MaterialPageRoute<void>(builder: (_) => ItemDetailPage(id: id));
  }

  @override
  State<ItemDetailPage> createState() => ItemDetailPageState();
}

@visibleForTesting
class ItemDetailPageState extends State<ItemDetailPage> {
  static const Key dataViewKey = Key('dataViewKey');
  final ItemDetailPageController controller = ItemDetailPageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) =>
            ref.watch(selectedItemsStateProvider(widget.id)).when(
                  data: (SelectedItemState state) => _SelectedItemDataView(
                    key: dataViewKey,
                    controller: controller,
                    tag: state.tag,
                    items: state.items,
                  ),
                  error: ErrorView.new,
                  loading: () => child!,
                ),
        child: const LoadingView(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push<void>(
          CreateItemPage.route(
            asModal: true,
            date: controller.date,
            tag: controller.tag,
          ),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _SelectedItemDataView extends StatefulWidget {
  const _SelectedItemDataView({super.key, required this.controller, required this.tag, required this.items});

  final ItemDetailPageController controller;
  final TagViewModel tag;
  final ItemViewModelList items;

  @override
  State<_SelectedItemDataView> createState() => _SelectedItemDataViewState();
}

class _SelectedItemDataViewState extends State<_SelectedItemDataView> {
  late final LinkedHashMap<DateTime, List<ItemViewModel>> _items = LinkedHashMap<DateTime, List<ItemViewModel>>(
    equals: isSameDay,
    hashCode: (DateTime key) => key.day * 1000000 + key.month * 10000 + key.year,
  );
  final ValueNotifier<DateTime> _focusedDay = ValueNotifier<DateTime>(kToday);

  DateTime get _selectedDay => _focusedDay.value;

  List<ItemViewModel> get _selectedItems => _getItemsForDay(_selectedDay);

  @override
  void initState() {
    super.initState();

    widget.controller.tag = widget.tag;
    _populateItems();
  }

  @override
  void didUpdateWidget(covariant _SelectedItemDataView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!listEquals(widget.items, oldWidget.items)) {
      _populateItems();
    }
  }

  List<ItemViewModel> _getItemsForDay(DateTime day) => _items[day] ?? <ItemViewModel>[];

  void _onFocusDay(DateTime focusedDay) => _focusedDay.value = focusedDay;

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _onFocusDay(focusedDay);
        widget.controller.date = focusedDay;
      });
    }
  }

  void _populateItems() {
    _items.clear();
    for (final ItemViewModel item in widget.items) {
      _items[item.date] = <ItemViewModel>[...?_items[item.date], item];
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = context.theme;

    const BoxDecoration headerBoxDecoration = BoxDecoration(
      gradient: LinearGradient(
        colors: <Color>[Colors.purpleAccent, Colors.blueAccent],
      ),
    );
    final TextStyle dayOfWeekTextStyle = theme.textTheme.labelSmall!.copyWith(
      color: theme.colorScheme.onBackground,
      fontWeight: FontWeight.w600,
    );

    return CustomScrollView(
      slivers: <Widget>[
        CustomAppBar(
          title: Text(widget.tag.title.capitalize()),
          actions: <Widget>[
            IconButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (BuildContext context) => Center(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: theme.canvasColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    margin: const EdgeInsets.all(16.0),
                    padding: const EdgeInsets.all(8.0),
                    child: Text(widget.tag.description),
                  ),
                ),
              ),
              icon: const Icon(Icons.info_outline),
              color: theme.colorScheme.onSurface,
            )
          ],
          asSliver: true,
        ),
        SliverPersistentHeader(
          delegate: _CustomSliverPersistentHeader(
            height: MediaQuery.of(context).size.height / 2.5,
            color: theme.colorScheme.surface,
            child: TableCalendar<ItemViewModel>(
              calendarFormat: CalendarFormat.month,
              startingDayOfWeek: StartingDayOfWeek.sunday,
              calendarStyle: const CalendarStyle(),
              currentDay: kToday,
              daysOfWeekHeight: 34,
              daysOfWeekStyle: DaysOfWeekStyle(
                decoration: BoxDecoration(
                  color: theme.colorScheme.inverseSurface,
                ),
                weekdayStyle: dayOfWeekTextStyle,
                weekendStyle: dayOfWeekTextStyle,
                dowTextFormatter: (DateTime day, dynamic locale) => DateFormat.E(locale).format(day).toUpperCase(),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                leftChevronVisible: false,
                rightChevronVisible: false,
                decoration: headerBoxDecoration,
                headerPadding: EdgeInsets.zero,
              ),
              shouldFillViewport: true,
              firstDay: DateTime(1970),
              lastDay: DateTime(kToday.year, kToday.month + 3, kToday.day),
              selectedDayPredicate: (DateTime day) => isSameDay(_selectedDay, day),
              onPageChanged: (DateTime focusedDay) => _onFocusDay(focusedDay),
              calendarBuilders: CalendarBuilders<ItemViewModel>(
                prioritizedBuilder: (BuildContext context, DateTime date, DateTime focusedDay) {
                  final bool isSelected = isSameDay(date, focusedDay);
                  final bool isToday = isSameDay(date, kToday) && !isSelected;
                  final bool isDisabled = date.month != focusedDay.month;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    margin: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: isToday
                          ? theme.colorScheme.inverseSurface
                          : isSelected
                              ? theme.colorScheme.primary
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        '${date.day}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: isDisabled ? FontWeight.normal : FontWeight.w700,
                          color: isDisabled
                              ? Colors.grey.shade400
                              : isToday
                                  ? theme.colorScheme.onPrimary
                                  : isSelected
                                      ? theme.colorScheme.onInverseSurface
                                      : theme.colorScheme.inverseSurface,
                        ),
                      ),
                    ),
                  );
                },
                headerTitleBuilder: (BuildContext context, DateTime value) => _CalendarHeader(
                  key: ValueKey<DateTime>(_selectedDay),
                  focusedDay: value,
                  onTodayButtonTap: () => setState(() => _onFocusDay(kToday)),
                ),
                singleMarkerBuilder: (BuildContext context, DateTime day, ItemViewModel item) {
                  final bool isSelected = isSameDay(day, _selectedDay);

                  return Container(
                    margin: const EdgeInsets.only(right: 2.0),
                    constraints: BoxConstraints.tight(const Size.square(6)),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? theme.colorScheme.onInverseSurface : item.tag.backgroundColor,
                      border: Border.all(color: item.tag.foregroundColor, width: isSelected ? 0 : .5),
                    ),
                  );
                },
              ),
              focusedDay: _selectedDay,
              eventLoader: _getItemsForDay,
              onDaySelected: _onDaySelected,
            ),
          ),
          pinned: true,
        ),
        ValueListenableBuilder<DateTime>(
          valueListenable: _focusedDay,
          builder: (BuildContext context, DateTime focusedDay, Widget? child) {
            final List<ItemViewModel> items = _selectedItems;
            final int count = items.length;

            if (count == 0) {
              return child!;
            }

            return SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 48),
              sliver: SliverList(
                delegate: SliverSeparatorBuilderDelegate.withHeader(
                  builder: (BuildContext context, int index) {
                    final ItemViewModel item = items[index];

                    return ItemListTile(
                      key: Key(item.id),
                      item: item,
                      canShowDate: false,
                      canNavigate: false,
                    );
                  },
                  separatorBuilder: (BuildContext context, __) => const SizedBox(height: 8),
                  headerBuilder: (BuildContext context) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: DefaultTextStyle(
                      style: theme.textTheme.labelSmall!.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        color: Colors.grey.shade600,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(DateFormat.yMMMEd().format(focusedDay).toUpperCase()),
                          Text(context.l10n.itemsCountCaption(count).toUpperCase()),
                        ],
                      ),
                    ),
                  ),
                  childCount: count,
                ),
              ),
            );
          },
          child: SliverFillRemaining(
            child: Center(
              child: Text(context.l10n.noItemsAvailableMessage),
            ),
          ),
        ),
      ],
    );
  }
}

class _CalendarHeader extends StatelessWidget {
  const _CalendarHeader({
    super.key,
    required this.focusedDay,
    required this.onTodayButtonTap,
  });

  final DateTime focusedDay;
  final VoidCallback onTodayButtonTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = context.theme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              DateFormat.yMMMM().format(focusedDay).toUpperCase(),
              style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.onBackground),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today, size: 20.0),
            color: theme.colorScheme.onBackground,
            visualDensity: VisualDensity.compact,
            onPressed: onTodayButtonTap,
          ),
        ],
      ),
    );
  }
}

class _CustomSliverPersistentHeader extends SliverPersistentHeaderDelegate {
  _CustomSliverPersistentHeader({
    required this.height,
    required this.color,
    required this.child,
  });

  final double height;
  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => Material(
        color: color,
        elevation: 5,
        shadowColor: Colors.black12,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: child,
        ),
      );

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => true;
}
