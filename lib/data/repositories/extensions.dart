import 'dart:math';

import 'package:clock/clock.dart';
import 'package:faker/faker.dart';
import 'package:iirc/core.dart';
import 'package:rxdart/transformers.dart';

import '../network/firebase/cloud_db.dart';
import '../network/firebase/exception.dart';
import '../network/firebase/models.dart';

extension ListExtensions<T> on Iterable<T> {
  Map<String, T> foldToMap(String Function(T) keyBuilder) => fold(
        <String, T>{},
        (Map<String, T> previousValue, T element) => <String, T>{...previousValue, keyBuilder(element): element},
      );
}

extension RandomGeneratorExtensions on RandomGenerator {
  DateTime get dateTime {
    final DateTime now = clock.now();
    final int year = now.year;
    final int month = now.month;
    return DateTime(
      integer(year, min: year),
      integer(min(month + 1, 12), min: max(month - 1, 0)),
      integer(29, min: 1),
      integer(23),
      integer(59),
    );
  }
}

extension RandomEnum<T extends Object> on Iterable<T> {
  T random() => elementAt(Random().nextInt(length - 1));
}

extension FetchEntriesCloudDbCollectionExtensions on CloudDbCollection {
  static const String entriesCollectionName = 'entries';

  String deriveEntriesPath(String userId, [String? id]) =>
      '$path/$userId/$entriesCollectionName${id != null ? '/$id' : ''}';

  Stream<List<T>> fetchEntries<T>({
    required String userId,
    String orderBy = 'createdAt',
    required Future<T> Function(MapDocumentSnapshot) mapper,
    required bool isDev,
  }) =>
      db
          .collection(deriveEntriesPath(userId))
          .orderBy(orderBy, descending: true)
          .snapshots()
          .asyncMap(
            (MapQuerySnapshot item) async => <T>[
              for (final MapDocumentSnapshot document in item.docs) await mapper(document),
            ],
          )
          .mapErrorToAppException(isDev);
}

extension AppExceptionStreamExtension<T> on Stream<T> {
  Stream<T> mapErrorToAppException(bool isDev) => onErrorResume((Object error, StackTrace stackTrace) {
        if (error is AppFirebaseException) {
          if (error.code == 'permission-denied' && !isDev) {
            return Stream<T>.empty();
          }
          handleUncaughtError(AppException(error.message ?? error.code), stackTrace);
        } else if (error is Error) {
          handleUncaughtError(AppException(error.toString()), error.stackTrace ?? stackTrace);
        } else {
          handleUncaughtError(AppException(error.toString()), stackTrace);
        }
        return Stream<T>.empty();
      });
}
