import 'package:iirc/domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models.dart';
import '../registry.dart';
import 'registry_provider.dart';
import 'user_provider.dart';

part 'tags_provider.g.dart';

@Riverpod(dependencies: <Object>[registry, user])
Stream<TagViewModelList> tags(TagsRef ref) async* {
  final Registry registry = ref.read(registryProvider);
  final UserEntity user = await ref.watch(userProvider.future);

  yield* registry
      .get<FetchTagsUseCase>()
      .call(user.id)
      .map((TagEntityList element) => element.map(TagViewModel.fromTag).toList());
}
