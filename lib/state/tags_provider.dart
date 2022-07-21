// ignore_for_file: always_specify_types

import 'package:iirc/data.dart';
import 'package:iirc/domain.dart';
import 'package:riverpod/riverpod.dart';

import 'registry_provider.dart';

final tagsProvider = StreamProvider.autoDispose<TagViewModelList>((ref) {
  final registry = ref.read(registryProvider);
  return registry.get<FetchTagsUseCase>().call().map((element) => element.map(TagViewModel.fromTag).toList());
});
