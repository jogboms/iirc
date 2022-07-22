import 'package:cloud_firestore/cloud_firestore.dart';

DateTime deriveDateFromTimestamp(Timestamp timestamp) => timestamp.toDate();
