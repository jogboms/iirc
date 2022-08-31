import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';

@immutable
class FireUser {
  factory FireUser(User reference) => FireUser._(
        uid: reference.uid,
        email: reference.email,
        displayName: reference.displayName,
      );

  const FireUser._({required this.uid, required this.email, required this.displayName});

  final String uid;
  final String? email;
  final String? displayName;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FireUser &&
          runtimeType == other.runtimeType &&
          uid == other.uid &&
          email == other.email &&
          displayName == other.displayName;

  @override
  int get hashCode => uid.hashCode ^ email.hashCode ^ displayName.hashCode;
}

typedef DynamicMap = Map<String, dynamic>;
typedef MapQuerySnapshot = QuerySnapshot<DynamicMap>;
typedef MapQueryDocumentSnapshot = QueryDocumentSnapshot<DynamicMap>;
typedef MapDocumentSnapshot = DocumentSnapshot<DynamicMap>;
typedef MapDocumentReference = DocumentReference<DynamicMap>;
typedef MapCollectionReference = CollectionReference<DynamicMap>;

typedef CloudTimestamp = Timestamp;
typedef CloudValue = FieldValue;
