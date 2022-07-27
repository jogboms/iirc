// ignore_for_file: always_specify_types

import 'package:riverpod/riverpod.dart';

import '../../../models/tag_view_model.dart';
import '../../../state/preserve_state_notifier.dart';
import '../../../state/search_tag_state_provider.dart';
import '../../../state/tags_provider.dart';

final _filteredTagsProvider = FutureProvider.autoDispose<TagViewModelList>(
  (ref) async => filterBySearchTagQuery(
    ref,
    elements: await ref.watch(tagsProvider.future),
    byTag: (element) => element,
  ),
);

final filteredTagsStateProvider =
    StateNotifierProvider.autoDispose<PreserveStateNotifier<TagViewModelList>, AsyncValue<TagViewModelList>>(
  (ref) => PreserveStateNotifier(_filteredTagsProvider, ref),
);
