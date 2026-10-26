import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../core/constants/firebase_collections.dart';
import '../models/user_model.dart';
import '../models/user_status.dart';
import '../services/firebase_service.dart';

class AuthRepository {
  // ═══════════════════════════════════════════
  //  SIGN UP (Owner/Admin only)
  // ═══════════════════════════════════════════
  Future<UserModel> signUp({
    required String fullName,
    required String companyName,
    required String email,
    required String phone,
    required String password,
  }) async {
    final cred = await FirebaseService.auth
        .createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final uid = cred.user!.uid;

    final user = UserModel(
      uid: uid,
      fullName: fullName.trim(),
      companyName: companyName.trim(),
      email: email.trim().toLowerCase(),
      phone: phone.trim(),
      role: UserRole.admin,
      status: UserStatus.pending,
      ownerId: uid,
      createdAt: DateTime.now(),
    );

    await FirebaseService.firestore
        .collection(FirebaseCollections.users)
        .doc(uid)
        .set(user.toSignupMap());

    // // Sign out — user will login after approval
    // await FirebaseService.auth.signOut();

    return user;
  }

  // ═══════════════════════════════════════════
  //  SIGN IN
  // ═══════════════════════════════════════════
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    final cred = await FirebaseService.auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final uid = cred.user!.uid;
    return fetchUser(uid);
  }

  // ═══════════════════════════════════════════
  //  FETCH USER
  // ═══════════════════════════════════════════
  Future<UserModel> fetchUser(String uid) async {
    try {
      final doc = await FirebaseService.firestore
          .collection(FirebaseCollections.users)
          .doc(uid)
          .get();

      if (!doc.exists) {
        throw Exception('User not found');
      }

      return UserModel.fromMap(uid, doc.data()!);
    } catch (e) {
      print('❌ fetchUser Error: $e');
      rethrow;
    }
  }

  // ═══════════════════════════════════════════
  //  REFRESH STATUS
  // ═══════════════════════════════════════════
  Future<UserStatus> refreshStatus(String uid) async {
    print('🔄 Refreshing status for uid: $uid');
    final user = await fetchUser(uid);
    print('✅ Fetched status: ${user.status.toFirestore()}');
    return user.status;
  }

  // ═══════════════════════════════════════════
  //  FETCH CURRENT USER
  // ═══════════════════════════════════════════
  Future<UserModel?> fetchCurrentUser() async {
    final current = FirebaseService.auth.currentUser;
    if (current == null) return null;
    return fetchUser(current.uid);
  }


  // ═══════════════════════════════════════════
  //  CREATE USER (Admin only, secondary auth)
  // ═══════════════════════════════════════════
  Future<UserModel> createUser({
    required String adminUid,
    required String adminCompanyName,
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required UserRole role,
  }) async {
    // ─── Use secondary Firebase app so admin session is intact ───
    final secondaryApp = await Firebase.initializeApp(
      name: 'create_user_${DateTime.now().millisecondsSinceEpoch}',
      options: Firebase.app().options,
    );

    try {
      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);

      // Create user via secondary auth
      final cred = await secondaryAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final newUid = cred.user!.uid;

      // Sign out secondary user
      await secondaryAuth.signOut();

      // Save to Firestore (admin session is active)
      final newUser = UserModel(
        uid: newUid,
        fullName: fullName.trim(),
        companyName: adminCompanyName.trim(),
        email: email.trim().toLowerCase(),
        phone: phone.trim(),
        role: role,
        status: UserStatus.approved,
        ownerId: adminUid,
        createdBy: adminUid,
        passwordPlain: password,
        createdAt: DateTime.now(),
      );

      await FirebaseService.firestore
          .collection(FirebaseCollections.users)
          .doc(newUid)
          .set(newUser.toCreateUserMap());

      return newUser;
    } finally {
      // Delete secondary app
      await secondaryApp.delete();
    }
  }

  // ═══════════════════════════════════════════
  //  FETCH TEAM MEMBERS (under an admin)
  // ═══════════════════════════════════════════
  Future<List<UserModel>> fetchTeamMembers(String adminUid) async {
    final query = await FirebaseService.firestore
        .collection(FirebaseCollections.users)
        .where('ownerId', isEqualTo: adminUid)
        .get();

    return query.docs
        .map((doc) => UserModel.fromMap(doc.id, doc.data()))
        .toList();
  }

  // ═══════════════════════════════════════════
  //  CHECK IF EMAIL IS REGISTERED
  // ═══════════════════════════════════════════
  Future<bool> isEmailRegistered(String email) async {
    try {
      final query = await FirebaseService.firestore
          .collection(FirebaseCollections.users)
          .where('email', isEqualTo: email.trim().toLowerCase())
          .limit(1)
          .get();
      return query.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // ═══════════════════════════════════════════
  //  SEND PASSWORD RESET
  // ═══════════════════════════════════════════
  Future<void> sendPasswordReset(String email) async {
    await FirebaseService.auth.sendPasswordResetEmail(
      email: email.trim().toLowerCase(),
    );
  }

  // ═══════════════════════════════════════════
  //  SIGN OUT
  // ═══════════════════════════════════════════
  Future<void> signOut() async {
    await FirebaseService.auth.signOut();
  }
}