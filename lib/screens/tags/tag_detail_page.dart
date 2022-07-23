import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iirc/core.dart';
import 'package:iirc/data.dart';
import 'package:iirc/domain.dart';
import 'package:iirc/widgets.dart';

import '../home/create_item_page.dart';
import '../widgets/item_calendar_list_view.dart';
import '../widgets/item_calendar_view.dart';
import 'providers/selected_tag_provider.dart';
import 'providers/tag_provider.dart';
import 'update_tag_page.dart';

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
    super.initState();

    itemCalendarViewController.addListener(() {
      widget.controller.date = itemCalendarViewController.value;
    });

    widget.controller.tag = widget.tag;
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
              onPressed: () {}, // TODO: route to insights details
              icon: const Icon(Icons.insights_outlined),
              color: theme.colorScheme.onSurface,
            ),
            const SizedBox(width: 4),
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
        ItemCalendarListView(
          controller: itemCalendarViewController,
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
