import 'package:cloud_firestore/cloud_firestore.dart';

abstract class DataReference<T> {
  DataReference();

  T get source;

  Future<void> delete();

  Future<void> setData(Map<String, dynamic> data, {bool merge = false});

  Future<void> updateData(Map<String, dynamic> data);
}

class FireReference implements DataReference<DocumentReference<Map<String, dynamic>>> {
  FireReference(this._reference);

  final DocumentReference<Map<String, dynamic>> _reference;

  @override
  DocumentReference<Map<String, dynamic>> get source => _reference;

  @override
  Future<void> delete() => _reference.delete();

  @override
  Future<void> setData(Map<String, dynamic> data, {bool merge = false}) =>
      _reference.set(data, SetOptions(merge: merge));

  @override
  Future<void> updateData(Map<String, dynamic> data) => _reference.update(data);
}

class MockDataReference implements DataReference<dynamic> {
  @override
  Future<void> delete() async {}

  @override
  Future<void> setData(Map<String, dynamic> data, {bool merge = false}) async {}

  @override
  dynamic get source => false;

  @override
  Future<void> updateData(Map<String, dynamic> data) async {}
}
