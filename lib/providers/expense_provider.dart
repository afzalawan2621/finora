import 'package:flutter/material.dart';

import '../models/expense_model.dart';
import '../repositories/expense_repository.dart';

class ExpenseProvider extends ChangeNotifier {
  final ExpenseRepository _repo = ExpenseRepository();

  List<ExpenseModel> _expenses = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<ExpenseModel> get expenses => _expenses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Calculated Stats
  double get totalAmount => _expenses.fold(0, (sum, e) => sum + e.amount);
  double get todayAmount {
    final today = DateTime.now();
    return _expenses
        .where((e) => e.date.year == today.year &&
        e.date.month == today.month &&
        e.date.day == today.day)
        .fold(0, (sum, e) => sum + e.amount);
  }
  double get thisMonthAmount {
    final now = DateTime.now();
    return _expenses
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .fold(0, (sum, e) => sum + e.amount);
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  void _setError(String? e) {
    _error = e;
    notifyListeners();
  }

  // ─── Fetch ───
  Future<void> fetchExpenses(String ownerId) async {
    _setLoading(true);
    _setError(null);
    try {
      _expenses = await _repo.fetchExpenses(ownerId);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ─── Add ───
  Future<bool> addExpense(ExpenseModel expense) async {
    try {
      await _repo.addExpense(expense);
      await fetchExpenses(expense.ownerId); // Refresh list
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // ─── Delete ───
  Future<bool> deleteExpense(ExpenseModel expense) async {
    try {
      await _repo.deleteExpense(expense.id);
      await fetchExpenses(expense.ownerId); // Refresh list
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }
}