import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'services/guest_storage_service.dart'; 



class GuestTransactionScreen extends StatefulWidget {
  const GuestTransactionScreen({super.key});

  @override
  State<GuestTransactionScreen> createState() => _GuestTransactionScreenState();
}

class _GuestTransactionScreenState extends State<GuestTransactionScreen> {
  final GuestStorageService _storageService = GuestStorageService();
  bool _isLoading = true;
  List<GuestTransaction> _transactions = [];
  List<String> _userCategories = [];
  final List<String> _transactionTypes = ['expense', 'income'];

  @override
  void initState() {
    super.initState();
    _fetchData(); 
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      
      final transactions = await _storageService.getTransactions();
      final categories = await _storageService.getTransactionCategories();
      
      setState(() {
        _transactions = transactions;
        _userCategories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load local transactions: $e')),
        );
      }
    }
  }

  Future<void> _showAddGuestTransactionDialog() async {
    final descriptionController = TextEditingController();
    final amountController = TextEditingController();
    final newCategoryController = TextEditingController();
    String? selectedType = 'expense';

    
    List<String> categoryOptions = [..._userCategories, "+ Add New Category"];
    String? selectedCategory;
    bool showNewCategoryField = false;

    if (_userCategories.isEmpty) {
      selectedCategory = "+ Add New Category";
      showNewCategoryField = true;
    } else {
      selectedCategory = categoryOptions.first;
    }

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) { 
            return AlertDialog(
              title: const Text('Add New Transaction'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(hintText: "Description"),
                    ),
                    TextField(
                      controller: amountController,
                      decoration: const InputDecoration(hintText: "Amount"),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedType,
                      decoration: const InputDecoration(labelText: 'Type'),
                      items: _transactionTypes.map((String type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type.isNotEmpty ? type[0].toUpperCase() + type.substring(1) : ''),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setStateDialog(() { 
                          selectedType = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: categoryOptions.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setStateDialog(() { 
                          selectedCategory = newValue;
                          if (newValue == "+ Add New Category") {
                            showNewCategoryField = true;
                          } else {
                            showNewCategoryField = false;
                          }
                        });
                      },
                    ),
                    if (showNewCategoryField)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: TextField(
                          controller: newCategoryController,
                          decoration: const InputDecoration(
                              hintText: "New Category Name"),
                          autofocus: true,
                        ),
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
                    
                    String finalCategory;
                    if (showNewCategoryField) {
                      finalCategory = newCategoryController.text;
                    } else {
                      finalCategory = selectedCategory ?? '';
                    }

                    if (amountController.text.isEmpty || finalCategory.isEmpty || selectedType == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill all fields')),
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

                    final newTransaction = GuestTransaction(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      description: descriptionController.text.isNotEmpty ? descriptionController.text : 'No description',
                      amount: amount,
                      type: selectedType!,
                      category: finalCategory,
                      createdAt: DateTime.now(),
                    );

                    try {
                      
                      await _storageService.addTransaction(newTransaction);
                      
                      
                      _fetchData(); 

                      if (mounted) {
                        Navigator.of(context).pop();
                      }
                    } catch (e) {
                       if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to save transaction: $e')),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Transactions (Guest)'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _transactions.isEmpty
            ? const Center(child: Text('No transactions added yet.'))
            : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _transactions.length,
              itemBuilder: (context, index) {
                final transaction = _transactions[index];
                final String formattedDate = DateFormat('MMMM d, yyyy').format(transaction.createdAt);
                
                final transactionMap = transaction.toMap(); 

                return Card(
                  elevation: 2.0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    leading: Icon(
                      transactionMap['type'] == 'income' ? Icons.arrow_upward : Icons.arrow_downward,
                      color: transactionMap['type'] == 'income' ? Colors.green : Colors.red,
                    ),
                    title: Text(transactionMap['description'] ?? 'No description', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("$formattedDate - ${transactionMap['category']}"), 
                    trailing: Text(
                      '₹${transactionMap['amount']}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: transactionMap['type'] == 'income' ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddGuestTransactionDialog,
        tooltip: 'Add Transaction',
        child: const Icon(Icons.add),
      ),
    );
  }
}