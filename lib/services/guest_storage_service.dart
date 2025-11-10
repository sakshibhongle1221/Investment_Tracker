import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';


class GuestTransaction {
  final String id;
  final String description;
  final double amount;
  final String type;
  final String category;
  final DateTime createdAt;

  GuestTransaction({
    required this.id,
    required this.description,
    required this.amount,
    required this.type,
    required this.category,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'type': type,
      'category': category,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory GuestTransaction.fromMap(Map<String, dynamic> map) {
    return GuestTransaction(
      id: map['id'],
      description: map['description'],
      amount: map['amount'],
      type: map['type'],
      category: map['category'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}

class GuestBudget {
  final String id;
  final String category;
  final double amount;

  
  GuestBudget({
    required this.id,
    required this.category,
    required this.amount,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'amount': amount,
    };
  }

  factory GuestBudget.fromMap(Map<String, dynamic> map) {
    return GuestBudget(
      id: map['id'],
      category: map['category'],
      amount: map['amount'],
    );
  }
}

class GuestGoal {
  final String id;
  final String title;
  final double targetAmount;
  final double savedAmount;

  GuestGoal({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.savedAmount,
  });

   Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'targetAmount': targetAmount,
      'savedAmount': savedAmount,
    };
  }

  factory GuestGoal.fromMap(Map<String, dynamic> map) {
    return GuestGoal(
      id: map['id'],
      title: map['title'],
      targetAmount: map['targetAmount'],
      savedAmount: map['savedAmount'],
    );
  }
}



class GuestStorageService {
  static const String _transactionsKey = 'guest_transactions';
  static const String _budgetsKey = 'guest_budgets';
  static const String _goalsKey = 'guest_goals';

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();


  Future<List<GuestTransaction>> getTransactions() async {
    final prefs = await _prefs;
    final jsonString = prefs.getString(_transactionsKey);
    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((map) => GuestTransaction.fromMap(map)).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return [];
  }

  Future<void> saveTransactions(List<GuestTransaction> transactions) async {
    final prefs = await _prefs;
    final List<Map<String, dynamic>> jsonList = transactions.map((t) => t.toMap()).toList();
    await prefs.setString(_transactionsKey, jsonEncode(jsonList));
  }

  Future<void> addTransaction(GuestTransaction transaction) async {
    final transactions = await getTransactions();
    transactions.insert(0, transaction); 
    await saveTransactions(transactions);
  }

  Future<List<String>> getTransactionCategories() async {
    final transactions = await getTransactions();
    final categories = transactions
        .map((t) => t.category)
        .toSet() 
        .toList();
    categories.sort(); 
    return categories;
  }

  Future<List<GuestBudget>> getBudgets() async {
    final prefs = await _prefs;
    final jsonString = prefs.getString(_budgetsKey);
    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((map) => GuestBudget.fromMap(map)).toList();
    }
    return [];
  }

  Future<void> saveBudgets(List<GuestBudget> budgets) async {
    final prefs = await _prefs;
    final List<Map<String, dynamic>> jsonList = budgets.map((b) => b.toMap()).toList();
    await prefs.setString(_budgetsKey, jsonEncode(jsonList));
  }

  Future<void> addBudget(GuestBudget budget) async {
    final budgets = await getBudgets();
    budgets.insert(0, budget);
    await saveBudgets(budgets);
  }


  Future<List<GuestGoal>> getGoals() async {
    final prefs = await _prefs;
    final jsonString = prefs.getString(_goalsKey);
    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((map) => GuestGoal.fromMap(map)).toList();
    }
    return [];
  }

  Future<void> saveGoals(List<GuestGoal> goals) async {
    final prefs = await _prefs;
    final List<Map<String, dynamic>> jsonList = goals.map((g) => g.toMap()).toList();
    await prefs.setString(_goalsKey, jsonEncode(jsonList));
  }

   Future<void> addGoal(GuestGoal goal) async {
    final goals = await getGoals();
    goals.insert(0, goal);
    await saveGoals(goals);
  }
}