import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseService {
  FirebaseService._();

  static FirebaseAuth get auth => FirebaseAuth.instance;
  static FirebaseFirestore get firestore =>
      FirebaseFirestore.instance;

  static Future<void> initialize({dynamic options}) async {
    await Firebase.initializeApp(options: options);
  }
}