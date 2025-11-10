import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'transactions_screen.dart';
import 'budgets_screen.dart';
import 'goals_screen.dart';

class MainScreen extends StatelessWidget{
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context){
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('InvestmentTracker'),
          elevation:0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black, 
          actions: [
            IconButton(icon: const Icon(Icons.search),onPressed: (){}),
            IconButton(icon: const Icon(Icons.person_outline),onPressed: (){}),
          ],
          bottom: const TabBar(
            labelColor : Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.green,
            tabs:[
              Tab(text: 'Dashboard'),
              Tab(text: 'Transactions'),
              Tab(text: 'Budget'),
              Tab(text: 'Goals'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            DashboardScreen(),
            TransactionsScreen(),
            BudgetsScreen(),
            GoalsScreen(),
          ],
        ),
      ),
    );
  }
}