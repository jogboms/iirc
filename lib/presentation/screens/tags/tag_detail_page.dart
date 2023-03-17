import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iirc/core.dart';
import 'package:iirc/domain.dart';

import '../../constants/app_routes.dart';
import '../../models.dart';
import '../../state.dart';
import '../../theme.dart';
import '../../utils.dart';
import '../../widgets.dart';
import '../items/create_item_page.dart';
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

  TagViewModel? get tag => _tag;
  TagViewModel? _tag;

  set tag(TagViewModel? tag) {
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
    return MaterialPageRoute<void>(
      builder: (_) => TagDetailPage(id: id),
      settings: const RouteSettings(name: AppRoutes.tagDetail),
    );
  }

  @override
  State<TagDetailPage> createState() => TagDetailPageState();
}

@visibleForTesting
class TagDetailPageState extends State<TagDetailPage> {
  static const Key dataViewKey = Key('dataViewKey');
  static const Key createItemButtonKey = Key('createItemButtonKey');
  final TagDetailPageController controller = TagDetailPageController();

  @override
  void dispose() {
    controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: () async {
          ScaffoldMessenger.of(context).removeCurrentMaterialBanner(reason: MaterialBannerClosedReason.dismiss);
          return true;
        },
        child: Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) =>
              ref.watch(selectedTagProvider(widget.id)).when(
                    skipLoadingOnReload: true,
                    data: (SelectedTagState state) => _SelectedTagDataView(
                      key: dataViewKey,
                      analytics: ref.read(analyticsProvider),
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
      floatingActionButton: Consumer(
        builder: (BuildContext context, WidgetRef ref, _) => FloatingActionButton(
          key: createItemButtonKey,
          onPressed: () {
            ref.read(analyticsProvider).log(AnalyticsEvent.buttonClick('create item'));
            Navigator.of(context).push<void>(
              CreateItemPage.route(
                asModal: true,
                date: controller.date,
                tag: controller.tag,
              ),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class _SelectedTagDataView extends StatefulWidget {
  const _SelectedTagDataView({
    super.key,
    required this.analytics,
    required this.controller,
    required this.tag,
    required this.items,
  });

  final Analytics analytics;
  final TagDetailPageController controller;
  final TagViewModel tag;
  final ItemViewModelList items;

  @override
  State<_SelectedTagDataView> createState() => SelectedTagDataViewState();
}

@visibleForTesting
class SelectedTagDataViewState extends State<_SelectedTagDataView> {
  static const Key updateItemButtonKey = Key('updateItemButtonKey');

  late final ItemCalendarViewController itemCalendarViewController = ItemCalendarViewController(
    date: widget.items.firstOrNull?.date,
  );

  @override
  void initState() {
    super.initState();

    itemCalendarViewController.addListener(() {
      widget.controller.date = itemCalendarViewController.selectedDate;
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
              onPressed: () {
                widget.analytics.log(AnalyticsEvent.buttonClick('view tag insights: ${widget.tag.id}'));
                // TODO(Jogboms): route to insights details
              },
              icon: const Icon(Icons.insights_outlined),
              color: theme.colorScheme.onSurface,
            ),
            const SizedBox(width: 4),
            IconButton(
              onPressed: () {
                widget.analytics.log(AnalyticsEvent.buttonClick('view tag info: ${widget.tag.id}'));
                showDialog<void>(
                  context: context,
                  builder: (BuildContext context) => Center(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: theme.canvasColor,
                        borderRadius: AppBorderRadius.c4,
                      ),
                      margin: const EdgeInsets.all(16.0),
                      padding: const EdgeInsets.all(8.0),
                      child: Text(widget.tag.description),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.info_outline),
              color: theme.colorScheme.onSurface,
            ),
            const SizedBox(width: 4),
            IconButton(
              key: updateItemButtonKey,
              onPressed: () {
                widget.analytics.log(AnalyticsEvent.buttonClick('edit tag: ${widget.tag.id}'));
                Navigator.of(context).push(UpdateTagPage.route(tag: widget.tag));
              },
              icon: const Icon(Icons.edit_outlined),
              color: theme.colorScheme.onSurface,
            ),
            if (widget.items.isEmpty) ...<Widget>[
              const SizedBox(width: 4),
              Consumer(
                builder: (_, WidgetRef ref, __) => IconButton(
                  onPressed: () async {
                    final AppSnackBar snackBar = context.snackBar;
                    final L10n l10n = context.l10n;
                    final NavigatorState navigator = Navigator.of(context);

                    unawaited(widget.analytics.log(AnalyticsEvent.buttonClick('delete tag: ${widget.tag.id}')));
                    final bool isOk = await showErrorChoiceBanner(
                      context,
                      message: context.l10n.areYouSureAboutThisMessage,
                    );
                    if (isOk) {
                      _onDelete(ref, l10n: l10n, snackBar: snackBar, navigator: navigator);
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
        ItemCalendarViewGroup(
          controller: itemCalendarViewController,
          items: widget.items,
          analytics: widget.analytics,
        ),
      ],
    );
  }

  void _onDelete(
    WidgetRef ref, {
    required L10n l10n,
    required AppSnackBar snackBar,
    required NavigatorState navigator,
  }) async {
    try {
      snackBar.loading();

      await ref.read(tagProvider).delete(widget.tag);

      snackBar.success(l10n.successfulMessage);
      return navigator.pop();
    } catch (error, stackTrace) {
      AppLog.e(error, stackTrace);
      snackBar.error(l10n.genericErrorMessage);
    } finally {
      snackBar.hide();
    }
  }
}
