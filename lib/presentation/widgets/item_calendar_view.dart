import 'dart:collection';

import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../models/item_view_model.dart';
import '../models/tag_view_model.dart';
import '../theme/app_border_radius.dart';
import '../theme/app_style.dart';
import '../theme/app_theme.dart';
import '../theme/extensions.dart';

DateTime get _kToday => clock.now();

class ItemCalendarViewController extends ValueNotifier<DateTime> {
  ItemCalendarViewController({
    @visibleForTesting this.height = 324,
    @visibleForTesting DateTime? date,
  }) : super(date ?? _kToday);

  final double height;
  final double weekDayHeight = kToolbarHeight * .75;

  List<ItemViewModel> get items => getItemsForDay(value);

  final LinkedHashMap<DateTime, List<ItemViewModel>> _items = LinkedHashMap<DateTime, List<ItemViewModel>>(
    equals: isSameDay,
    hashCode: (DateTime key) => key.day * 1000000 + key.month * 10000 + key.year,
  );

  void today() => forceUpdate(_kToday);

  @visibleForTesting
  void update(DateTime focusedDay) => value = focusedDay;

  @visibleForTesting
  bool get forcedUpdate => _forcedUpdate;
  bool _forcedUpdate = false;

  @visibleForTesting
  void forceUpdate(DateTime focusedDay) {
    _forcedUpdate = true;
    update(focusedDay);
  }

  @visibleForTesting
  void reset() {
    _forcedUpdate = false;
  }

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
  const ItemCalendarView({
    super.key,
    required this.controller,
    required this.items,
  });

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
    widget.controller.addListener(_forceUpdate);
  }

  @override
  void didUpdateWidget(covariant ItemCalendarView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!listEquals(widget.items, oldWidget.items)) {
      widget.controller.populate(widget.items);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_forceUpdate);

    super.dispose();
  }

  void _forceUpdate() {
    if (widget.controller.forcedUpdate) {
      setState(() => widget.controller.reset());
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(widget.controller.value, selectedDay)) {
      widget.controller.forceUpdate(focusedDay);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = context.theme;

    final TextStyle dayOfWeekTextStyle = theme.textTheme.labelSmall!.copyWith(
      color: theme.colorScheme.onBackground,
      fontWeight: AppFontWeight.semibold,
    );

    return SliverPersistentHeader(
      delegate: _CustomSliverPersistentHeader(
        height: widget.controller.height,
        color: theme.colorScheme.surface,
        child: TableCalendar<ItemViewModel>(
          calendarFormat: CalendarFormat.month,
          startingDayOfWeek: StartingDayOfWeek.sunday,
          currentDay: _kToday,
          daysOfWeekHeight: kToolbarHeight * .75,
          headerVisible: false,
          sixWeekMonthsEnforced: true,
          daysOfWeekStyle: DaysOfWeekStyle(
            decoration: BoxDecoration(
              color: theme.colorScheme.inverseSurface,
            ),
            weekdayStyle: dayOfWeekTextStyle,
            weekendStyle: dayOfWeekTextStyle,
            dowTextFormatter: (DateTime day, dynamic locale) => DateFormat.E(locale).format(day).toUpperCase(),
          ),
          shouldFillViewport: true,
          firstDay: DateTime(0),
          lastDay: DateTime(_kToday.year + 2),
          selectedDayPredicate: (DateTime day) => isSameDay(widget.controller.value, day),
          onPageChanged: widget.controller.update,
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
                  borderRadius: AppBorderRadius.c4,
                ),
                child: Center(
                  child: Text(
                    '${date.day}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: isDisabled ? AppFontWeight.regular : AppFontWeight.semibold,
                      color: isDisabled
                          ? theme.appTheme.hintColor.shade400
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
            singleMarkerBuilder: (BuildContext context, DateTime day, ItemViewModel item) => _ItemMarker(
              key: ObjectKey(item.tag),
              tag: item.tag,
              isSelected: isSameDay(day, widget.controller.value),
            ),
          ),
          focusedDay: widget.controller.value,
          eventLoader: widget.controller.getItemsForDay,
          onDaySelected: _onDaySelected,
        ),
      ),
    );
  }
}

class _ItemMarker extends StatelessWidget {
  const _ItemMarker({super.key, required this.isSelected, required this.tag});

  final bool isSelected;
  final TagViewModel tag;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = context.theme;

    return Container(
      margin: const EdgeInsets.only(right: 2.0),
      constraints: BoxConstraints.tight(const Size.square(6)),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? theme.colorScheme.onInverseSurface : tag.backgroundColor,
        border: Border.all(color: tag.foregroundColor, width: isSelected ? 0 : .5),
      ),
    );
  }
}

class _CustomSliverPersistentHeader extends SliverPersistentHeaderDelegate {
  const _CustomSliverPersistentHeader({
    required this.height,
    required this.color,
    required this.child,
  });

  final double height;
  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context, _, __) => Material(
        color: color,
        elevation: 5,
        shadowColor: context.theme.shadowColor,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: child,
        ),
      );

  @override
  double get maxExtent => minExtent;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(covariant _CustomSliverPersistentHeader oldDelegate) =>
      height != oldDelegate.height || color != oldDelegate.color || child != oldDelegate.child;
}
