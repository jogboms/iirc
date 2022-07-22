import 'dart:math';

import 'package:clock/clock.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faker/faker.dart';
import 'package:iirc/core.dart';
import 'package:rxdart/transformers.dart';

extension ListExtensions<T> on Iterable<T> {
  Map<String, T> foldToMap(String Function(T) keyBuilder) => fold(<String, T>{},
      (Map<String, T> previousValue, T element) => <String, T>{...previousValue, keyBuilder(element): element});
}

extension RandomGeneratorExtensions on RandomGenerator {
  DateTime get dateTime {
    final int year = clock.now().year;
    return DateTime(
      integer(year, min: year - 5),
      integer(12, min: 1),
      integer(29, min: 1),
      integer(23, min: 0),
      integer(59, min: 0),
    );
  }
}

extension RandomEnum<T extends Object> on Iterable<T> {
  T random() => elementAt(Random().nextInt(length - 1));
}

extension AppExceptionStreamExtension<T> on Stream<T> {
  Stream<T> mapErrorToAppException(bool isDev) => onErrorResume((Object error, [StackTrace? stackTrace]) {
        stackTrace ??= StackTrace.current;
        if (error is FirebaseException) {
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
