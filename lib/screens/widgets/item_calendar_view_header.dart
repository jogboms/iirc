import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iirc/core.dart';
import 'package:intl/intl.dart';

import 'item_calendar_view.dart';

class ItemCalendarViewHeader extends StatelessWidget {
  const ItemCalendarViewHeader({super.key, required this.controller, this.primary = false});

  final ItemCalendarViewController controller;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = context.theme;
    final ScrollPosition scrollPosition = Scrollable.of(context)!.position;
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
                const BoxShadow(offset: Offset(0, 1), blurRadius: 5, spreadRadius: 2, color: Colors.black12),
            ],
            gradient: LinearGradient(
              colors: isCalendarWeekHiddenFromView
                  ? List<Color>.filled(2, theme.colorScheme.inverseSurface)
                  : theme.calendarViewHeaderGradient,
            ),
          ),
          child: ValueListenableBuilder<DateTime>(
            valueListenable: controller,
            builder: (BuildContext context, DateTime value, _) => _CalendarHeader(
              key: ObjectKey(value),
              focusedDay: value,
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

        return SliverPersistentHeader(
          pinned: true,
          delegate: _CustomSliverPersistentHeader(
            height: height,
            child: widget,
          ),
        );
      },
    );
  }
}

class _CustomSliverPersistentHeader extends SliverPersistentHeaderDelegate {
  _CustomSliverPersistentHeader({required this.height, required this.child});

  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context, _, __) => child;

  @override
  double get maxExtent => minExtent;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(covariant _CustomSliverPersistentHeader oldDelegate) =>
      height != oldDelegate.height || child != oldDelegate.child;
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
            icon: const Icon(Icons.calendar_today_outlined, size: 20.0),
            color: theme.colorScheme.onBackground,
            visualDensity: VisualDensity.compact,
            onPressed: onPressedToday,
          ),
          if (onPressedScrollToTop != null)
            IconButton(
              icon: const Icon(Icons.vertical_align_top_outlined, size: 20.0),
              color: theme.colorScheme.onBackground,
              visualDensity: VisualDensity.compact,
              onPressed: onPressedScrollToTop,
            ),
        ],
      ),
    );
  }
}
