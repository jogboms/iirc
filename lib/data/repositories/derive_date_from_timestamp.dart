import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;

DateTime deriveDateFromTimestamp(Timestamp timestamp) => timestamp.toDate();
