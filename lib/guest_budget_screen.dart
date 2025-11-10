import 'package:flutter/material.dart';
import 'services/guest_storage_service.dart'; 

class GuestBudgetScreen extends StatefulWidget {
  const GuestBudgetScreen({super.key});

  @override
  State<GuestBudgetScreen> createState() => _GuestBudgetScreenState();
}

class _GuestBudgetScreenState extends State<GuestBudgetScreen> {
  final GuestStorageService _storageService = GuestStorageService();
  bool _isLoading = true;
  List<GuestBudget> _guestBudgets = []; 

  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchBudgets();
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _amountController.dispose();
    super.dispose();
  }



  Future<void> _fetchBudgets() async {
    setState(() { _isLoading = true; });
    try {
      final budgets = await _storageService.getBudgets();
      setState(() {
        _guestBudgets = budgets;
        _isLoading = false;
      });
    } catch (e) {
      setState(() { _isLoading = false; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load budgets: $e')),
        );
      }
    }
  }

  Future<void> _showAddGuestBudgetDialog() async {
    _categoryController.clear();
    _amountController.clear();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Budget'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: _categoryController,
                  decoration: const InputDecoration(hintText: "Category (e.g., Food)"),
                ),
                TextField(
                  controller: _amountController,
                  decoration: const InputDecoration(hintText: "Amount (e.g., 5000)"),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () async { 
                final String category = _categoryController.text;
                final double? amount = double.tryParse(_amountController.text);

                if (category.isEmpty || amount == null) {
                   ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a valid category and amount')),
                    );
                  return;
                }

                final newGuestBudget = GuestBudget(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  category: category,
                  amount: amount,
                );

                try {
                  await _storageService.addBudget(newGuestBudget);
                  _fetchBudgets(); 
                  
                  if (mounted) {
                    Navigator.of(context).pop();
                  }
                } catch (e) {
                   if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to save budget: $e')),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Budgets (Guest)'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _guestBudgets.isEmpty
            ? const Center(child: Text('No budgets added yet.'))
            : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _guestBudgets.length,
              itemBuilder: (context, index) {
                final guestBudget = _guestBudgets[index];
              
                double spent = 0.0; 
                double amount = guestBudget.amount;
                double progress = (amount > 0) ? spent / amount : 0;

                return Card(
                  elevation: 2.0,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          guestBudget.category,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('Spent ₹$spent of ₹$amount'),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.grey[300],
                          color: progress > 1 ? Colors.red : Colors.green,
                          minHeight: 10,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddGuestBudgetDialog,
        tooltip: 'Add Budget',
        child: const Icon(Icons.add),
      ),
    );
  }
}