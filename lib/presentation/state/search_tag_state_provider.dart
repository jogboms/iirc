import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'state_notifier_mixin.dart';

part 'search_tag_state_provider.g.dart';

enum SearchTagMode { title, description }

@riverpod
class SearchTagQueryState extends _$SearchTagQueryState with StateNotifierMixin {
  @override
  String build() => '';
}

@riverpod
class SearchTagModeState extends _$SearchTagModeState with StateNotifierMixin {
  @override
  SearchTagMode build() => SearchTagMode.title;
}

List<T> filterBySearchTagQuery<T, U>(
  AutoDisposeRef<U> ref, {
  required List<T> elements,
  required String Function(T) byTitle,
  required String Function(T) byDescription,
}) {
  final String query = ref.watch(searchTagQueryStateProvider).trim().toLowerCase();
  final SearchTagMode mode = ref.watch(searchTagModeStateProvider);

  return elements.where((T element) {
    if (query.length > 1) {
      switch (mode) {
        case SearchTagMode.title:
          return byTitle(element).toLowerCase().contains(query);
        case SearchTagMode.description:
          return byDescription(element).toLowerCase().contains(query);
      }
    }

    return true;
  }).toList(growable: false);
}
