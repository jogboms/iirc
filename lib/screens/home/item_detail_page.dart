import 'dart:collection';

import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iirc/core.dart';
import 'package:iirc/domain.dart';
import 'package:iirc/widgets.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import 'item_list_tile.dart';
import 'providers/selected_items_provider.dart';

final DateTime kToday = clock.now();

class ItemDetailPage extends StatefulWidget {
  const ItemDetailPage({super.key, required this.id});

  final String id;

  static PageRoute<void> route(BuildContext context, {required String id}) {
    return MaterialPageRoute<void>(builder: (_) => ItemDetailPage(id: id));
  }

  @override
  State<ItemDetailPage> createState() => ItemDetailPageState();
}

@visibleForTesting
class ItemDetailPageState extends State<ItemDetailPage> {
  static const Key dataViewKey = Key('dataViewKey');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) =>
            ref.watch(selectedItemsStateProvider(widget.id)).when(
                  data: (SelectedItemState state) => _SelectedItemDataView(
                    key: dataViewKey,
                    tag: state.tag,
                    items: state.items,
                  ),
                  error: ErrorView.new,
                  loading: () => child!,
                ),
        child: const LoadingView(),
      ),
    );
  }
}

class _SelectedItemDataView extends StatefulWidget {
  const _SelectedItemDataView({super.key, required this.tag, required this.items});

  final TagModel tag;
  final ItemModelList items;

  @override
  State<_SelectedItemDataView> createState() => _SelectedItemDataViewState();
}

class _SelectedItemDataViewState extends State<_SelectedItemDataView> {
  late final LinkedHashMap<DateTime, List<ItemModel>> _items = LinkedHashMap<DateTime, List<ItemModel>>(
    equals: isSameDay,
    hashCode: (DateTime key) => key.day * 1000000 + key.month * 10000 + key.year,
  );
  final ValueNotifier<DateTime> _focusedDay = ValueNotifier<DateTime>(kToday);
  late final ValueNotifier<List<ItemModel>> _selectedItems =
      ValueNotifier<List<ItemModel>>(_getItemsForDay(_selectedDay!));

  DateTime? get _selectedDay => _focusedDay.value;

  @override
  void initState() {
    super.initState();

    _populateItems();
  }

  @override
  void didUpdateWidget(covariant _SelectedItemDataView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!listEquals(widget.items, oldWidget.items)) {
      _populateItems();
    }
  }

  @override
  void dispose() {
    _selectedItems.dispose();

    super.dispose();
  }

  List<ItemModel> _getItemsForDay(DateTime day) => _items[day] ?? <ItemModel>[];

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {});

      _focusedDay.value = focusedDay;
      _selectedItems.value = _getItemsForDay(selectedDay);
    }
  }

  void _populateItems() {
    _items.clear();
    for (final ItemModel item in widget.items) {
      _items[item.date] = <ItemModel>[...?_items[item.date], item];
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
        SliverAppBar(
          pinned: true,
          elevation: 0,
          backgroundColor: theme.colorScheme.surface,
          leading: BackButton(color: theme.colorScheme.onSurface),
          centerTitle: false,
          title: Text(
            widget.tag.title.capitalize(),
            style: theme.textTheme.titleLarge?.copyWith(height: 1),
          ),
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
        ),
        SliverPersistentHeader(
          delegate: _CustomSliverPersistentHeader(
            height: MediaQuery.of(context).size.height / 2.5,
            color: theme.colorScheme.surface,
            child: TableCalendar<ItemModel>(
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
              onPageChanged: (DateTime focusedDay) => _focusedDay.value = focusedDay,
              calendarBuilders: CalendarBuilders<ItemModel>(
                prioritizedBuilder: (BuildContext context, DateTime date, DateTime focusedDay) {
                  final bool isSelected = isSameDay(date, focusedDay);
                  final bool isToday = isSameDay(date, kToday) && !isSelected;

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
                          color: isToday
                              ? theme.colorScheme.onPrimary
                              : isSelected
                                  ? theme.colorScheme.onInverseSurface
                                  : theme.colorScheme.inverseSurface,
                        ),
                      ),
                    ),
                  );
                },
                headerTitleBuilder: (_, DateTime value) => _CalendarHeader(
                  key: ValueKey<DateTime>(_focusedDay.value),
                  focusedDay: value,
                  onTodayButtonTap: () {
                    setState(() => _focusedDay.value = kToday);
                  },
                ),
                singleMarkerBuilder: (BuildContext context, DateTime day, ItemModel item) => Container(
                  margin: const EdgeInsets.only(right: 2.0),
                  constraints: BoxConstraints.tight(const Size.square(6)),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(item.tag.color),
                    border: Border.all(color: Colors.grey.shade600),
                  ),
                ),
              ),
              focusedDay: _focusedDay.value,
              eventLoader: _getItemsForDay,
              onDaySelected: _onDaySelected,
            ),
          ),
          pinned: true,
        ),
        ValueListenableBuilder<ItemModelList>(
          valueListenable: _selectedItems,
          builder: (BuildContext context, ItemModelList items, _) {
            final int count = items.length;

            if (count == 0) {
              return SliverFillRemaining(
                child: Center(
                  child: Text(context.l10n.noItemsAvailableMessage),
                ),
              );
            }

            return SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 48),
              sliver: SliverList(
                delegate: SliverSeparatorBuilderDelegate.withHeader(
                  builder: (BuildContext context, int index) {
                    final ItemModel item = items[index];

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
                    child: Text(
                      context.l10n.itemsCaption.capitalize() + ' ($count)',
                      style: theme.textTheme.labelLarge,
                    ),
                  ),
                  childCount: count,
                ),
              ),
            );
          },
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
