import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'services/api_service.dart';

class DashboardScreen extends StatefulWidget{
  const DashboardScreen({super.key});

  @override 
  State<DashboardScreen> createState()=> _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>{
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<dynamic> _transactions = [];
  List<dynamic> _summaryData = [];
  Map<String,dynamic> _dashboardStats = {};
  List<dynamic> _investmentData = [];
  

  @override
  void initState(){
    super.initState();
    _fetchData();
  }

  Future<void>_fetchData() async{
    setState((){
      _isLoading = true;
    });
    try{
      final results = await Future.wait([ 
      _apiService.getTransactions(),
      _apiService.getTransactionSummary(),
      _apiService.getDashboardStats(),
      _apiService.getInvestmentPerformance(),
      ]);
      setState((){
       _transactions = results[0] as List<dynamic>;
       _summaryData = results[1] as List<dynamic>;
       _dashboardStats = results[2] as Map<String, dynamic>;
       _investmentData = results[3] as List<dynamic>;
       _isLoading =false;        
      });
    }
    catch(e){
      setState((){
        _isLoading = false;
      });
      if (mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load dashboard data:$e')),
        );
      }
    }
  }

  Future<void> _showAddInformationDialog() async {
    final amountController = TextEditingController();
    final descriptionController = TextEditingController(text: 'Income'); 
    
    return showDialog<void>(
      context: context,
      builder:(BuildContext context){
        return StatefulBuilder(
         builder: (context,setState){
          return AlertDialog(
          title: const Text('Add Income'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(hintText:"Income Amount"),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(hintText:"Description (e.g., Salary)"),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
            child: const Text('Cancel'),
            onPressed:(){
              Navigator.of(context).pop(); 
            },  
            ),
            TextButton(
              child: const Text('Save'),
              onPressed:() async{

                if(amountController.text.isEmpty){
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill the amount field')),
                    );
                    return;
                } 

                final double? amount = double.tryParse(amountController.text);
                if (amount == null) {
                   ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a valid amount')),
                    );
                    return;
                }

                try{
                  
                  await _apiService.addTransaction(
                    amount,
                    'income', 
                    'Income',
                    descriptionController.text.isNotEmpty ? descriptionController.text : 'Income'
                  );

                  if (mounted) {
                    Navigator.of(context).pop();
                    _fetchData();
                  }
                }
                catch (e) {
                  if (mounted) {
                     ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to add income: $e')),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
      },
    );
  }

@override
Widget build(BuildContext context) {
  final textTheme = Theme.of(context).textTheme;
  return Scaffold(
   // appBar: AppBar(
   //   title: const Text('My Dashboard'),
   //   centerTitle: true,
   //   automaticallyImplyLeading: false,
   //   actions: [
   //     IconButton(
   //       icon: const Icon(Icons.        account_balance_wallet),
   //       tooltip: 'Budgets',
   //       onPressed: () {
   //         Navigator.pushNamed(context, '/budgets');
   //       },
   //     ),
   //     IconButton(
   //       icon: const Icon(Icons.flag),
   //       tooltip: 'Goals',
   //       onPressed:(){
   //         Navigator.pushNamed(context,'/goals');
   //       },
   //     ),
   //   ],
   //  ),
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
                            Text('Total Savings', style: textTheme.bodyMedium),
                            Text('₹${_dashboardStats['netWorth'] ?? 0}', style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold,
                            fontSize:22,)),
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
                            Text('₹${_dashboardStats['totalIncome'] ?? 0}', style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold,
                            fontSize:22,)),
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
                            Text('₹${_dashboardStats['totalExpenses'] ?? 0}', style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold,
                            fontSize:22)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // --- EXPENSE SUMMARY CARD ---
              Card(
                elevation: 2.0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Expense Summary', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
                      SizedBox(
                        height: 200,
                        child: PieChart(
                          PieChartData(
                            sections: _summaryData.map((item) {
                              return PieChartSectionData(
                                color: Colors.primaries[(_summaryData.indexOf(item)) % Colors.primaries.length],
                                value: double.parse(item['total_amount']),
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
              ),
              const SizedBox(height: 16),

              // --- RECENT TRANSACTIONS CARD ---
        /*      Card(
                elevation: 2.0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Recent Transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      // We use ...map here because it's already inside a scrolling ListView
                      _transactions.take(5).map((transaction) {
                          return ListTile(
                            title: Text(transaction['description'] ?? 'No description'),
                            subtitle: Text(transaction['category'] ?? 'Uncategorized'),
                            trailing: Text(
                              '₹${transaction['amount']}',
                              style: TextStyle(
                                color: transaction['type'] == 'income' ? Colors.green : Colors.red,
                              ),
                            ),
                          );
                      }).toList(),
                    ],
                  ),
                ),
              ),  */

/*              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Investment Performance', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 200,
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(show: false),
                            titlesData: FlTitlesData(show: false),
                            borderData: FlBorderData(show: false),
                            lineBarsData:[
                            LineChartBarData(
                              spots: _investmentData.asMap().entries.map((entry){
                                return FlSpot(entry.key.toDouble(),entry.value['value'].toDouble());
                              }).toList(),
                              isCurved: true,
                              color: Colors.green,
                              barWidth: 4,
                              isStrokeCapRound: true,
                              dotData: FlDotData(show: true),
                              belowBarData: BarAreaData(
                                show:true,
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
              ), */
       ],
    ),

    floatingActionButton: FloatingActionButton(
                onPressed: _showAddInformationDialog,
                tooltip: 'Add Information',
                child: const Icon(Icons.add),
            ),
    
  );
}

}
