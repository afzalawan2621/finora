import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/firebase_collections.dart';
import '../models/expense_model.dart';
import '../services/firebase_service.dart';

class ExpenseRepository {
  // ─── Add ───
  Future<void> addExpense(ExpenseModel expense) async {
    await FirebaseService.firestore
        .collection(FirebaseCollections.expenses)
        .add(expense.toMap());
  }

  // ─── Fetch (by ownerId) ───
  Future<List<ExpenseModel>> fetchExpenses(String ownerId) async {
    final snapshot = await FirebaseService.firestore
        .collection(FirebaseCollections.expenses)
        .where('ownerId', isEqualTo: ownerId)
    // ❌ orderBy hata diya (index error se bachne ke liye)
        .get();

    final list = snapshot.docs
        .map((doc) => ExpenseModel.fromMap(doc.id, doc.data()))
        .toList();

    // ✅ Manually sort karo (latest pehle)
    list.sort((a, b) => b.date.compareTo(a.date));

    return list;
  }

  // ─── Delete (Admin only) ───
  Future<void> deleteExpense(String expenseId) async {
    await FirebaseService.firestore
        .collection(FirebaseCollections.expenses)
        .doc(expenseId)
        .delete();
  }

  // ─── Update (Admin only) ───
  Future<void> updateExpense(ExpenseModel expense) async {
    await FirebaseService.firestore
        .collection(FirebaseCollections.expenses)
        .doc(expense.id)
        .update(expense.toMap());
  }
}