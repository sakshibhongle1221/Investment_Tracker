import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'services/guest_storage_service.dart'; 
import 'dart:math'; 

class GuestDashboardScreen extends StatefulWidget {
  const GuestDashboardScreen({super.key});

  @override
  State<GuestDashboardScreen> createState() => _GuestDashboardScreenState();
}

class _GuestDashboardScreenState extends State<GuestDashboardScreen> {
  final GuestStorageService _storageService = GuestStorageService();
  bool _isLoading = true;

  
  List<dynamic> _summaryData = [];
  Map<String, dynamic> _dashboardStats = {};
  
  
  List<dynamic> _investmentData = [
      {'value': 1000.0},
      {'value': 1200.0},
      {'value': 1100.0},
      {'value': 1300.0},
      {'value': 1500.0},
      {'value': 1450.0},
      {'value': 1800.0},
      {'value': 1700.0},
  ];

  @override
  void initState() {
    super.initState();
    _fetchData(); 
  }

 

  Future<void> _fetchData() async {
    setState(() { _isLoading = true; });

    try {
      
      final transactions = await _storageService.getTransactions();

      
      double totalIncome = 0;
      double totalExpenses = 0;
      final Map<String, double> categoryTotals = {};

      for (final t in transactions) {
        if (t.type == 'income') {
          totalIncome += t.amount;
        } else if (t.type == 'expense') {
          totalExpenses += t.amount;
          
          categoryTotals.update(t.category, (value) => value + t.amount, ifAbsent: () => t.amount);
        }
      }

      double netWorth = totalIncome - totalExpenses;

      
      final calculatedStats = {
        'netWorth': netWorth,
        'totalIncome': totalIncome,
        'totalExpenses': totalExpenses,
      };

      
      final calculatedSummary = categoryTotals.entries.map((entry) {
        return {
          'category': entry.key,
          'total_amount': entry.value.toString(),  
        };
      }).toList();

      setState(() {
        _dashboardStats = calculatedStats;
        _summaryData = calculatedSummary;
        
        _isLoading = false;
      });

    } catch (e) {
      setState(() { _isLoading = false; });
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load dashboard data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard (Guest)'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt, color: Colors.black),
            tooltip: 'Transactions',
            onPressed: () {
             
              Navigator.pushNamed(context, '/guest_transaction')
                  .then((_) => _fetchData());
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_balance_wallet, color: Colors.black),
            tooltip: 'Budgets',
            onPressed: () {
            
              Navigator.pushNamed(context, '/guest_budget')
                  .then((_) => _fetchData());
            },
          ),
          IconButton(
            icon: const Icon(Icons.flag, color: Colors.black),
            tooltip: 'Goals',
            onPressed: () {
              
              Navigator.pushNamed(context, '/guest_goal')
                  .then((_) => _fetchData());
            },
          ),
          TextButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Login or Sign Up'),
                  content: const Text(
                      'Your guest data will be lost. To save your data, please create an account. Continue to login?'),
                  actions: [
                    TextButton(
                      child: const Text('Cancel'),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                    ),
                    TextButton(
                      child: const Text('Continue'),
                      onPressed: () {
                        
                        Navigator.of(ctx).pop();
                        Navigator.of(context).pushReplacementNamed('/login');
                      },
                    ),
                  ],
                ),
              );
            },
            child: const Text(
              'Login / Sign Up',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Net Worth', style: textTheme.bodyMedium),
                              Text('₹${_dashboardStats['netWorth']?.toStringAsFixed(2) ?? 0.00}', 
                                  style: textTheme.titleLarge
                                      ?.copyWith(fontWeight: FontWeight.bold, fontSize: 22)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Income', style: textTheme.bodyMedium),
                              Text('₹${_dashboardStats['totalIncome']?.toStringAsFixed(2) ?? 0.00}',
                                  style: textTheme.titleLarge
                                      ?.copyWith(fontWeight: FontWeight.bold, fontSize: 22)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Expenses', style: textTheme.bodyMedium),
                              Text('₹${_dashboardStats['totalExpenses']?.toStringAsFixed(2) ?? 0.00}',
                                  style: textTheme.titleLarge
                                      ?.copyWith(fontWeight: FontWeight.bold, fontSize: 22)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                
                if (_summaryData.isNotEmpty)
                  Card(
                    elevation: 2.0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                    child: Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Expense Summary',
                              style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
                          SizedBox(
                            height: 200,
                            child: PieChart(
                              PieChartData(
                                sections: _summaryData.map((item) {
                                  final index = _summaryData.indexOf(item);
                                  final color = Colors.primaries[index % Colors.primaries.length];
                                  
                                  return PieChartSectionData(
                                    color: color,
                                    value: double.tryParse(item['total_amount'] ?? '0'),
                                    title: '${item['category']}',
                                    radius: 80,
                                    titleStyle: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  );
                                }).toList(),
                                centerSpaceRadius: 40,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(30.0),
                      child: Center(
                        child: Text('No expense data for summary.'),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                
                
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Investment Performance',
                            style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 200,
                          child: LineChart(
                            LineChartData(
                              gridData: FlGridData(show: false),
                              titlesData: FlTitlesData(show: false),
                              borderData: FlBorderData(show: false),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: _investmentData.asMap().entries.map((entry) {
                                    return FlSpot(entry.key.toDouble(), entry.value['value'].toDouble());
                                  }).toList(),
                                  isCurved: true,
                                  color: Colors.green,
                                  barWidth: 4,
                                  isStrokeCapRound: true,
                                  dotData: FlDotData(show: true),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: Colors.green.withOpacity(0.3),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
    );
  }
}