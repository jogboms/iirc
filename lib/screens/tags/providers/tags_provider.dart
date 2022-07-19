// ignore_for_file: always_specify_types

import 'package:iirc/domain.dart';
import 'package:iirc/registry.dart';
import 'package:iirc/state.dart';
import 'package:riverpod/riverpod.dart';

final _tagsProvider = StreamProvider<TagModelList>((StreamProviderRef<TagModelList> ref) {
  final Registry registry = ref.read(registryProvider);
  return registry.get<FetchTagsUseCase>().call();
});

final tagsStateProvider =
    StateNotifierProvider.autoDispose<PreserveStateNotifier<TagModelList>, AsyncValue<TagModelList>>(
  (ref) => PreserveStateNotifier(_tagsProvider, ref),
);
