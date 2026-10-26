import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/firebase_collections.dart';
import '../models/income_model.dart';
import '../services/firebase_service.dart';

class IncomeRepository {
  // ─── Add ───
  Future<void> addIncome(IncomeModel income) async {
    await FirebaseService.firestore
        .collection(FirebaseCollections.incomes)
        .add(income.toMap());
  }

  // ─── Fetch (by ownerId) ───
  Future<List<IncomeModel>> fetchIncomes(String ownerId) async {
    final snapshot = await FirebaseService.firestore
        .collection(FirebaseCollections.incomes)
        .where('ownerId', isEqualTo: ownerId)
    // ❌ orderBy hata diya (index error se bachne ke liye)
        .get();

    final list = snapshot.docs
        .map((doc) => IncomeModel.fromMap(doc.id, doc.data()))
        .toList();

    // ✅ Manually sort karo (latest pehle)
    list.sort((a, b) => b.date.compareTo(a.date));

    return list;
  }

  // ─── Delete (Admin only) ───
  Future<void> deleteIncome(String incomeId) async {
    await FirebaseService.firestore
        .collection(FirebaseCollections.incomes)
        .doc(incomeId)
        .delete();
  }

  // ─── Update (Admin only) ───
  Future<void> updateIncome(IncomeModel income) async {
    await FirebaseService.firestore
        .collection(FirebaseCollections.incomes)
        .doc(income.id)
        .update(income.toMap());
  }
}