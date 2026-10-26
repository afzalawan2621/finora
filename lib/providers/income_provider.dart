import 'package:flutter/material.dart';

import '../models/income_model.dart';
import '../repositories/income_repository.dart';

class IncomeProvider extends ChangeNotifier {
  final IncomeRepository _repo = IncomeRepository();

  List<IncomeModel> _incomes = [];
  bool _isLoading = false;
  String? _error;

  List<IncomeModel> get incomes => _incomes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get totalAmount => _incomes.fold(0.0, (sum, e) => sum + e.amount);

  // ✅ Ye naya getter add karo
  double get thisMonthAmount {
    final now = DateTime.now();
    return _incomes
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  double get pendingAmount => _incomes
      .where((e) => e.status == IncomeStatus.pending)
      .fold(0.0, (sum, e) => sum + e.amount);

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  void _setError(String? e) {
    _error = e;
    notifyListeners();
  }

  Future<void> fetchIncomes(String ownerId) async {
    _setLoading(true);
    _setError(null);
    try {
      _incomes = await _repo.fetchIncomes(ownerId);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addIncome(IncomeModel income) async {
    try {
      await _repo.addIncome(income);
      await fetchIncomes(income.ownerId);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> deleteIncome(IncomeModel income) async {
    try {
      await _repo.deleteIncome(income.id);
      await fetchIncomes(income.ownerId);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }
}