import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iirc/domain.dart';

import 'tags_provider.dart';

final StateProvider<String> selectedTagIdProvider = StateProvider<String>((StateProviderRef<String> ref) => '');

final StateProvider<TagModel?> selectedTagProvider = StateProvider<TagModel?>((StateProviderRef<TagModel?> ref) {
  final String id = ref.watch(selectedTagIdProvider);

  return ref.watch(tagsProvider).when(
        data: (TagModelList data) => data.firstWhere((TagModel element) => element.id == id),
        error: (Object error, _) => null,
        loading: () => null,
      );
});
