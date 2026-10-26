import 'package:flutter/material.dart';

import '../models/budget_model.dart';
import '../repositories/budget_repository.dart';

class BudgetProvider extends ChangeNotifier {
  final BudgetRepository _repo = BudgetRepository();

  BudgetModel? _currentBudget;
  bool _isLoading = false;
  String? _error;

  BudgetModel? get currentBudget => _currentBudget;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get totalBudget => _currentBudget?.totalBudget ?? 0;
  Map<String, double> get categoryLimits => _currentBudget?.categoryLimits ?? {};

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  void _setError(String? e) {
    _error = e;
    notifyListeners();
  }

  Future<void> fetchBudget(String ownerId, String monthKey) async {
    _setLoading(true);
    _setError(null);
    try {
      _currentBudget = await _repo.fetchBudget(ownerId, monthKey);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> saveBudget(BudgetModel budget) async {
    try {
      await _repo.saveBudget(budget);
      await fetchBudget(budget.ownerId, budget.monthKey);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }
}