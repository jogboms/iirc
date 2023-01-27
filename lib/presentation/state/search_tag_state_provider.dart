// ignore_for_file: always_specify_types

import 'package:riverpod/riverpod.dart';

enum SearchTagMode { title, description }

final searchTagQueryStateProvider = StateProvider.autoDispose<String>((ref) => '');

final searchTagModeStateProvider = StateProvider.autoDispose<SearchTagMode>((ref) => SearchTagMode.title);

List<T> filterBySearchTagQuery<T>(
  AutoDisposeRef ref, {
  required List<T> elements,
  required String Function(T) byTitle,
  required String Function(T) byDescription,
}) {
  final String query = ref.watch(searchTagQueryStateProvider).trim().toLowerCase();
  final SearchTagMode mode = ref.watch(searchTagModeStateProvider);

  return elements.where((element) {
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
