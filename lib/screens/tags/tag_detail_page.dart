import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iirc/core.dart';
import 'package:iirc/data.dart';
import 'package:iirc/domain.dart';
import 'package:iirc/widgets.dart';
import 'package:intl/intl.dart';

import '../home/create_item_page.dart';
import '../home/item_detail_page.dart';
import '../widgets/item_calendar_view.dart';
import '../widgets/item_list_tile.dart';
import 'providers/selected_tag_provider.dart';
import 'providers/tag_provider.dart';
import 'update_tag_page.dart';

final DateTime kToday = clock.now();

@visibleForTesting
class TagDetailPageController with ChangeNotifier {
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

class TagDetailPage extends StatefulWidget {
  const TagDetailPage({super.key, required this.id});

  final String id;

  static PageRoute<void> route({required String id}) {
    return MaterialPageRoute<void>(builder: (_) => TagDetailPage(id: id));
  }

  @override
  State<TagDetailPage> createState() => TagDetailPageState();
}

@visibleForTesting
class TagDetailPageState extends State<TagDetailPage> {
  static const Key dataViewKey = Key('dataViewKey');
  final TagDetailPageController controller = TagDetailPageController();

  @override
  void dispose() {
    controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: WillPopScope(
        onWillPop: () async {
          ScaffoldMessenger.of(context).removeCurrentMaterialBanner(reason: MaterialBannerClosedReason.dismiss);
          return true;
        },
        child: Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) =>
              ref.watch(selectedTagStateProvider(widget.id)).when(
                    data: (SelectedTagState state) => _SelectedTagDataView(
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

class _SelectedTagDataView extends StatefulWidget {
  const _SelectedTagDataView({super.key, required this.controller, required this.tag, required this.items});

  final TagDetailPageController controller;
  final TagViewModel tag;
  final ItemViewModelList items;

  @override
  State<_SelectedTagDataView> createState() => _SelectedTagDataViewState();
}

class _SelectedTagDataViewState extends State<_SelectedTagDataView> {
  final ItemCalendarViewController itemCalendarViewController = ItemCalendarViewController();

  @override
  void initState() {
    itemCalendarViewController.addListener(() {
      widget.controller.date = itemCalendarViewController.date;
    });

    super.initState();
  }

  @override
  void dispose() {
    itemCalendarViewController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = context.theme;

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
            ),
            const SizedBox(width: 4),
            IconButton(
              onPressed: () => Navigator.of(context).push(UpdateTagPage.route(tag: widget.tag)),
              icon: const Icon(Icons.edit_outlined),
              color: theme.colorScheme.onSurface,
            ),
            if (widget.items.isEmpty) ...<Widget>[
              const SizedBox(width: 4),
              Consumer(
                builder: (BuildContext context, WidgetRef ref, _) => IconButton(
                  onPressed: () async {
                    final bool isOk = await showErrorChoiceBanner(
                      context,
                      message: context.l10n.areYouSureAboutThisMessage,
                    );
                    if (isOk) {
                      _onDelete(context, ref);
                    }
                  },
                  icon: const Icon(Icons.delete_forever_outlined),
                  color: theme.colorScheme.error,
                ),
              ),
            ],
            const SizedBox(width: 2),
          ],
          asSliver: true,
        ),
        ItemCalendarView(
          controller: itemCalendarViewController,
          items: widget.items,
        ),
        AnimatedBuilder(
          animation: itemCalendarViewController,
          builder: (BuildContext context, Widget? child) {
            final ItemViewModelList items = itemCalendarViewController.items;
            final DateTime focusedDay = itemCalendarViewController.date;
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
                      onPressed: () => Navigator.of(context).push<void>(ItemDetailPage.route(id: item.id)),
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

  void _onDelete(BuildContext context, WidgetRef ref) async {
    await ref.read(tagProvider).delete(widget.tag);

    // TODO: Handle loading state.
    // TODO: Handle error state.

    return Navigator.pop(context);
  }
}
