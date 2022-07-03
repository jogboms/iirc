import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iirc/domain.dart';

import 'tags_provider.dart';

final StateProvider<String> selectedTagIdProvider = StateProvider<String>((StateProviderRef<String> ref) => '');

final AutoDisposeFutureProvider<TagModel> selectedTagProvider =
    FutureProvider.autoDispose((AutoDisposeFutureProviderRef<TagModel> ref) async {
  final String id = ref.watch(selectedTagIdProvider);
  final TagModelList tags = await ref.watch(tagsProvider.future);

  return tags.firstWhere((TagModel element) => element.id == id);
});
