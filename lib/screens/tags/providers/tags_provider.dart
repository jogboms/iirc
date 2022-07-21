// ignore_for_file: always_specify_types

import 'package:iirc/data.dart';
import 'package:iirc/domain.dart';
import 'package:iirc/registry.dart';
import 'package:iirc/state.dart';
import 'package:riverpod/riverpod.dart';

final _tagsProvider = StreamProvider.autoDispose<TagViewModelList>((ref) {
  final Registry registry = ref.read(registryProvider);
  return registry.get<FetchTagsUseCase>().call().map((element) => element.map(TagViewModel.fromTag).toList());
});

final _filteredTagsProvider = FutureProvider.autoDispose<TagViewModelList>(
  (ref) async => filterBySearchTagTitleQuery(
    ref,
    elements: await ref.watch(_tagsProvider.future),
    byKey: (element) => element.title,
  ),
);

final tagsStateProvider =
    StateNotifierProvider.autoDispose<PreserveStateNotifier<TagViewModelList>, AsyncValue<TagViewModelList>>(
  (ref) => PreserveStateNotifier(_filteredTagsProvider, ref),
);
