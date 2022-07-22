import 'package:cloud_firestore/cloud_firestore.dart';

class CloudDb {
  CloudDb(this.instance);

  final FirebaseFirestore instance;
}

class FireStoreDb {
  FireStoreDb(this.instance, this.path);

  final FirebaseFirestore instance;

  final String path;

  CollectionReference<Map<String, dynamic>> fetchAll() => instance.collection(path);

  DocumentReference<Map<String, dynamic>> fetchOne(String uuid) => instance.doc('$path/$uuid');
}
