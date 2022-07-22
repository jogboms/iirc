import 'package:cloud_firestore/cloud_firestore.dart';

import 'models.dart';

abstract class DataReference<T> {
  DataReference();

  T get source;

  Future<void> delete();

  Future<void> setData(DynamicMap data, {bool merge = false});

  Future<void> updateData(DynamicMap data);
}

class FireReference implements DataReference<MapDocumentReference> {
  FireReference(this._reference);

  final MapDocumentReference _reference;

  @override
  MapDocumentReference get source => _reference;

  @override
  Future<void> delete() => _reference.delete();

  @override
  Future<void> setData(DynamicMap data, {bool merge = false}) => _reference.set(data, SetOptions(merge: merge));

  @override
  Future<void> updateData(DynamicMap data) => _reference.update(data);
}

class MockDataReference implements DataReference<dynamic> {
  @override
  Future<void> delete() async {}

  @override
  Future<void> setData(DynamicMap data, {bool merge = false}) async {}

  @override
  dynamic get source => false;

  @override
  Future<void> updateData(DynamicMap data) async {}
}
