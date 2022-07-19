import 'dart:collection';

import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iirc/core.dart';
import 'package:iirc/data.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

final DateTime _kToday = clock.now();

class ItemCalendarViewController extends ValueNotifier<DateTime> {
  ItemCalendarViewController({
    @visibleForTesting DateTime? date,
  }) : super(date ?? _kToday);

  List<ItemViewModel> get items => getItemsForDay(value);

  final LinkedHashMap<DateTime, List<ItemViewModel>> _items = LinkedHashMap<DateTime, List<ItemViewModel>>(
    equals: isSameDay,
    hashCode: (DateTime key) => key.day * 1000000 + key.month * 10000 + key.year,
  );

  @visibleForTesting
  void populate(ItemViewModelList items) {
    _items.clear();
    for (final ItemViewModel item in items) {
      _items[item.date] = <ItemViewModel>[...?_items[item.date], item];
    }
  }

  @visibleForTesting
  List<ItemViewModel> getItemsForDay(DateTime day) => _items[day] ?? <ItemViewModel>[];
}

class ItemCalendarView extends StatefulWidget {
  const ItemCalendarView({super.key, required this.controller, required this.items});

  final ItemCalendarViewController controller;
  final ItemViewModelList items;

  @override
  State<ItemCalendarView> createState() => _ItemCalendarViewState();
}

class _ItemCalendarViewState extends State<ItemCalendarView> {
  @override
  void initState() {
    super.initState();

    widget.controller.populate(widget.items);
  }

  @override
  void didUpdateWidget(covariant ItemCalendarView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!listEquals(widget.items, oldWidget.items)) {
      widget.controller.populate(widget.items);
    }
  }

  void _onFocusDay(DateTime focusedDay) => widget.controller.value = focusedDay;

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(widget.controller.value, selectedDay)) {
      setState(() {
        _onFocusDay(focusedDay);
      });
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

    return SliverPersistentHeader(
      delegate: _CustomSliverPersistentHeader(
        height: MediaQuery.of(context).size.height / 2.5,
        color: theme.colorScheme.surface,
        child: TableCalendar<ItemViewModel>(
          calendarFormat: CalendarFormat.month,
          startingDayOfWeek: StartingDayOfWeek.sunday,
          calendarStyle: const CalendarStyle(),
          currentDay: _kToday,
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
          lastDay: DateTime(_kToday.year, _kToday.month + 3, _kToday.day),
          selectedDayPredicate: (DateTime day) => isSameDay(widget.controller.value, day),
          onPageChanged: (DateTime focusedDay) => _onFocusDay(focusedDay),
          calendarBuilders: CalendarBuilders<ItemViewModel>(
            prioritizedBuilder: (BuildContext context, DateTime date, DateTime focusedDay) {
              final bool isSelected = isSameDay(date, focusedDay);
              final bool isToday = isSameDay(date, _kToday) && !isSelected;
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
              key: ValueKey<DateTime>(widget.controller.value),
              focusedDay: value,
              onTodayButtonTap: () => setState(() => _onFocusDay(_kToday)),
            ),
            singleMarkerBuilder: (BuildContext context, DateTime day, ItemViewModel item) {
              final bool isSelected = isSameDay(day, widget.controller.value);

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
          focusedDay: widget.controller.value,
          eventLoader: widget.controller.getItemsForDay,
          onDaySelected: _onDaySelected,
        ),
      ),
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
