import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:sliver_tools/sliver_tools.dart';

import '../theme.dart';
import 'item_calendar_view.dart';

class ItemCalendarViewHeader extends StatelessWidget {
  const ItemCalendarViewHeader({super.key, required this.controller, this.primary = false});

  final ItemCalendarViewController controller;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = context.theme;
    final ScrollPosition scrollPosition = Scrollable.of(context).position;
    final double safeArea = primary ? MediaQuery.of(context).padding.top : 0;
    final double height = kToolbarHeight + safeArea;

    return AnimatedBuilder(
      animation: scrollPosition,
      builder: (BuildContext context, _) {
        final bool isCalendarWeekHiddenFromView = scrollPosition.pixels > controller.weekDayHeight;
        final bool isCalendarHiddenFromView = scrollPosition.pixels > controller.height + height;

        Widget widget = AnimatedContainer(
          duration: kThemeAnimationDuration,
          height: height,
          padding: EdgeInsets.only(top: safeArea),
          decoration: BoxDecoration(
            boxShadow: <BoxShadow>[
              if (isCalendarHiddenFromView)
                BoxShadow(
                  offset: const Offset(0, 1),
                  blurRadius: 5,
                  spreadRadius: 2,
                  color: context.theme.shadowColor,
                ),
            ],
            gradient: LinearGradient(
              colors: isCalendarWeekHiddenFromView
                  ? List<Color>.filled(2, theme.colorScheme.calenderViewHeaderContainer)
                  : theme.colorScheme.calendarViewHeaderGradient,
            ),
          ),
          child: AnimatedBuilder(
            animation: controller,
            builder: (BuildContext context, _) => _CalendarHeader(
              key: ObjectKey(controller.focusedDay),
              focusedDay: controller.focusedDay,
              onPressedToday: controller.today,
              onPressedScrollToTop: isCalendarHiddenFromView
                  ? () => scrollPosition.animateTo(0, duration: kThemeAnimationDuration, curve: Curves.easeInOut)
                  : null,
            ),
          ),
        );

        if (safeArea != 0) {
          widget = AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.light,
            child: widget,
          );
        }

        return SliverPinnedHeader(
          child: widget,
        );
      },
    );
  }
}

class _CalendarHeader extends StatelessWidget {
  const _CalendarHeader({
    super.key,
    required this.focusedDay,
    required this.onPressedToday,
    this.onPressedScrollToTop,
  });

  final DateTime focusedDay;
  final VoidCallback onPressedToday;
  final VoidCallback? onPressedScrollToTop;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = context.theme;
    final Color color = theme.colorScheme.calenderViewColor;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              DateFormat.yMMMM().format(focusedDay).toUpperCase(),
              style: theme.textTheme.titleSmall?.copyWith(color: color),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined, size: 20.0),
            color: color,
            visualDensity: VisualDensity.compact,
            onPressed: onPressedToday,
          ),
          if (onPressedScrollToTop != null)
            IconButton(
              icon: const Icon(Icons.vertical_align_top_outlined, size: 20.0),
              color: color,
              visualDensity: VisualDensity.compact,
              onPressed: onPressedScrollToTop,
            ),
        ],
      ),
    );
  }
}
