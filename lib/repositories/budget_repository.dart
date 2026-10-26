import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/firebase_collections.dart';
import '../models/budget_model.dart';
import '../services/firebase_service.dart';

class BudgetRepository {
  // ─── Fetch budget for a specific month ───
  Future<BudgetModel?> fetchBudget(String ownerId, String monthKey) async {
    // ❌ Do where clauses hata diye (index error se bachne ke liye)
    // ✅ Ek where clause + manual filter use karenge
    final snapshot = await FirebaseService.firestore
        .collection(FirebaseCollections.budgets)
        .where('ownerId', isEqualTo: ownerId)
        .get();

    // Manually filter by monthKey
    final matches = snapshot.docs.where((doc) {
      return doc.data()['monthKey'] == monthKey;
    }).toList();

    if (matches.isEmpty) return null;

    return BudgetModel.fromMap(
      matches.first.id,
      matches.first.data(),
    );
  }

  // ─── Create / Update budget ───
  Future<void> saveBudget(BudgetModel budget) async {
    final snapshot = await FirebaseService.firestore
        .collection(FirebaseCollections.budgets)
        .where('ownerId', isEqualTo: budget.ownerId)
        .get();

    // Manually filter by monthKey
    final matches = snapshot.docs.where((doc) {
      return doc.data()['monthKey'] == budget.monthKey;
    }).toList();

    if (matches.isNotEmpty) {
      // Update existing
      await FirebaseService.firestore
          .collection(FirebaseCollections.budgets)
          .doc(matches.first.id)
          .update(budget.toMap());
    } else {
      // Create new
      await FirebaseService.firestore
          .collection(FirebaseCollections.budgets)
          .add(budget.toMap());
    }
  }
}