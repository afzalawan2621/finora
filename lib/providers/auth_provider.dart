import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../models/user_status.dart';
import '../repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repo = AuthRepository();

  UserModel? _user;
  bool _isLoading = false;
  String? _error;
  List<UserModel> _teamMembers = [];

  // ─── Getters ───
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;
  bool get isApproved => _user?.status == UserStatus.approved;
  bool get isPending => _user?.status == UserStatus.pending;
  List<UserModel> get teamMembers => _teamMembers;

  // ─── Role helpers ───
  bool get isAdmin => _user?.role == UserRole.admin;
  bool get isManager => _user?.role == UserRole.manager;
  bool get isUser => _user?.role == UserRole.user;

  // ─── Permission helpers ───
  bool get canEdit => isAdmin;
  bool get canDelete => isAdmin;
  bool get canCreateUser => isAdmin;
  bool get canAccessAccounts => isAdmin;

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  void _setError(String? e) {
    _error = e;
    notifyListeners();
  }

  void _setUser(UserModel? u) {
    _user = u;
    notifyListeners();
  }

  Future<UserModel?> signUp({
    required String fullName,
    required String companyName,
    required String email,
    required String phone,
    required String password,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final user = await _repo.signUp(
        fullName: fullName,
        companyName: companyName,
        email: email,
        phone: phone,
        password: password,
      );

      // ✅ User set karo — waiting approval screen pe details dikhengi
      _setUser(user);

      return user;
    } catch (e) {
      _setError(_parseError(e));
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // ═══════════════════════════════════════════
  //  SIGN IN
  // ═══════════════════════════════════════════
  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final user = await _repo.signIn(
        email: email,
        password: password,
      );
      _setUser(user);
      return user;
    } catch (e) {
      _setError(_parseError(e));
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // ═══════════════════════════════════════════
  //  AUTO-LOGIN
  // ═══════════════════════════════════════════
  Future<UserModel?> autoLogin() async {
    _setLoading(true);
    try {
      final user = await _repo.fetchCurrentUser();
      _setUser(user);
      return user;
    } catch (e) {
      _setUser(null);
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<UserStatus?> refreshStatus() async {
    if (_user == null) return null;
    try {
      final status = await _repo.refreshStatus(_user!.uid);
      _setUser(_user!.copyWith(status: status));
      return status;
    } catch (e) {
      return null;
    }
  }

  // ═══════════════════════════════════════════
  //  CREATE USER (admin only)
  // ═══════════════════════════════════════════
  Future<UserModel?> createUser({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required UserRole role,
  }) async {
    if (_user == null || !isAdmin) {
      _setError('Only admin can create users');
      return null;
    }

    _setLoading(true);
    _setError(null);
    try {
      final newUser = await _repo.createUser(
        adminUid: _user!.uid,
        adminCompanyName: _user!.companyName,
        fullName: fullName,
        email: email,
        phone: phone,
        password: password,
        role: role,
      );

      // Refresh team list
      await fetchTeamMembers();

      return newUser;
    } catch (e) {
      _setError(_parseError(e));
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // ═══════════════════════════════════════════
  //  FETCH TEAM MEMBERS
  // ═══════════════════════════════════════════
  Future<void> fetchTeamMembers() async {
    if (_user == null) return;
    try {
      final members = await _repo.fetchTeamMembers(_user!.uid);
      _teamMembers = members;
      notifyListeners();
    } catch (e) {
      _teamMembers = [];
      notifyListeners();
    }
  }

  // ═══════════════════════════════════════════
  //  FORGOT PASSWORD
  // ═══════════════════════════════════════════
  Future<String> checkEmailAndSendReset(String email) async {
    _setLoading(true);
    _setError(null);

    try {
      final registered = await _repo.isEmailRegistered(email);

      if (!registered) {
        _setLoading(false);
        return 'not_registered';
      }

      await _repo.sendPasswordReset(email);
      _setLoading(false);
      return 'sent';
    } catch (e) {
      _setError(_parseError(e));
      _setLoading(false);
      return 'error';
    }
  }

  // ═══════════════════════════════════════════
  //  SIGN OUT
  // ═══════════════════════════════════════════
  Future<void> signOut() async {
    await _repo.signOut();
    _setUser(null);
    _teamMembers = [];
    notifyListeners();
  }

  // ═══════════════════════════════════════════
  //  ERROR PARSER
  // ═══════════════════════════════════════════
  String _parseError(Object e) {
    final s = e.toString();
    if (s.contains('email-already-in-use')) {
      return 'This email is already registered';
    }
    if (s.contains('weak-password')) {
      return 'Password is too weak';
    }
    if (s.contains('invalid-email')) {
      return 'Invalid email address';
    }
    if (s.contains('user-not-found')) {
      return 'No account found with this email';
    }
    if (s.contains('wrong-password')) {
      return 'Incorrect password';
    }
    if (s.contains('invalid-credential')) {
      return 'Invalid email or password';
    }
    if (s.contains('network-request-failed')) {
      return 'Network error. Check your connection';
    }
    if (s.contains('too-many-requests')) {
      return 'Too many attempts. Try again later';
    }
    return 'Something went wrong. Please try again';
  }
}