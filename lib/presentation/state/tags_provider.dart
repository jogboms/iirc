// ignore_for_file: always_specify_types

import 'package:iirc/domain.dart';
import 'package:riverpod/riverpod.dart';

import '../models/tag_view_model.dart';
import 'registry_provider.dart';
import 'user_provider.dart';

final tagsProvider = StreamProvider.autoDispose<TagViewModelList>((ref) async* {
  final registry = ref.read(registryProvider);
  final user = await ref.watch(userProvider.future);

  yield* registry.get<FetchTagsUseCase>().call(user.id).map((element) => element.map(TagViewModel.fromTag).toList());
});
