import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FireUser {
  FireUser(this._reference);

  final User _reference;

  String get uid => _reference.uid;

  String? get email => _reference.email;

  String? get displayName => _reference.displayName;
}

typedef DynamicMap = Map<String, dynamic>;
typedef MapQuerySnapshot = QuerySnapshot<DynamicMap>;
typedef MapQueryDocumentSnapshot = QueryDocumentSnapshot<DynamicMap>;
typedef MapDocumentSnapshot = DocumentSnapshot<DynamicMap>;
typedef MapDocumentReference = DocumentReference<DynamicMap>;
typedef MapCollectionReference = CollectionReference<DynamicMap>;

typedef CloudTimestamp = Timestamp;
typedef CloudValue = FieldValue;
