// ignore_for_file: always_specify_types

import 'package:iirc/domain.dart';
import 'package:riverpod/riverpod.dart';

enum SearchTagMode { title, description }

final searchTagQueryStateProvider = StateProvider<String>((ref) => '');

final searchTagModeStateProvider = StateProvider<SearchTagMode>((ref) => SearchTagMode.title);

List<T> filterBySearchTagQuery<T>(
  AutoDisposeFutureProviderRef<List<T>> ref, {
  required List<T> elements,
  required TagModel Function(T) byTag,
}) {
  final String query = ref.watch(searchTagQueryStateProvider).trim().toLowerCase();
  final SearchTagMode mode = ref.watch(searchTagModeStateProvider);

  return elements.where((element) {
    if (query.length > 1) {
      final tag = byTag(element);
      switch (mode) {
        case SearchTagMode.title:
          return tag.title.toLowerCase().contains(query);
        case SearchTagMode.description:
          return tag.description.toLowerCase().contains(query);
      }
    }

    return true;
  }).toList(growable: false);
}
