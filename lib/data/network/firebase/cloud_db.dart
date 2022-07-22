import 'package:cloud_firestore/cloud_firestore.dart';

import 'models.dart';

class CloudDb {
  CloudDb(this.instance);

  final FirebaseFirestore instance;
}

class FireStoreDb {
  FireStoreDb(this.instance, this.path);

  final FirebaseFirestore instance;

  final String path;

  CollectionReference<DynamicMap> fetchAll() => instance.collection(path);

  DocumentReference<DynamicMap> fetchOne(String uuid) => instance.doc('$path/$uuid');
}
