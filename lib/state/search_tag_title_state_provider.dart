// ignore_for_file: always_specify_types

import 'package:riverpod/riverpod.dart';

final searchTagTitleStateProvider = StateProvider<String>((ref) => '');

List<T> filterBySearchTagTitleQuery<T>(
  AutoDisposeFutureProviderRef<List<T>> ref, {
  required List<T> elements,
  required String Function(T) byKey,
}) {
  final String query = ref.watch(searchTagTitleStateProvider).trim();

  return elements.where((element) {
    if (query.length > 1) {
      return byKey(element).contains(query);
    }

    return true;
  }).toList(growable: false);
}
