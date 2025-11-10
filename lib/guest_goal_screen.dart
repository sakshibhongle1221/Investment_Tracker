import 'package:flutter/material.dart';
import 'services/guest_storage_service.dart'; 

class GuestGoalScreen extends StatefulWidget {
  const GuestGoalScreen({super.key});

  @override
  State<GuestGoalScreen> createState() => _GuestGoalScreenState();
}

class _GuestGoalScreenState extends State<GuestGoalScreen> {
  final GuestStorageService _storageService = GuestStorageService();
  bool _isLoading = true;
  List<GuestGoal> _guestGoals = []; 

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _targetAmountController = TextEditingController();
  final TextEditingController _savedAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchGoals(); 
  }

  @override
  void dispose() {
    _titleController.dispose();
    _targetAmountController.dispose();
    _savedAmountController.dispose();
    super.dispose();
  }

  

  Future<void> _fetchGoals() async {
    setState(() { _isLoading = true; });
    try {
      final goals = await _storageService.getGoals();
      setState(() {
        _guestGoals = goals;
        _isLoading = false;
      });
    } catch (e) {
      setState(() { _isLoading = false; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load goals: $e')),
        );
      }
    }
  }

  Future<void> _showAddGuestGoalDialog() async {
    _titleController.clear();
    _targetAmountController.clear();
    _savedAmountController.clear();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Goal'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(hintText: "Goal (e.g., New Phone)"),
                ),
                TextField(
                  controller: _targetAmountController,
                  decoration: const InputDecoration(hintText: "Target Amount (e.g., 50000)"),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _savedAmountController,
                  decoration: const InputDecoration(hintText: "Amount Already Saved (e.g., 0)"),
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
                final String title = _titleController.text;
                final double? targetAmount = double.tryParse(_targetAmountController.text);
                final double savedAmount = double.tryParse(_savedAmountController.text) ?? 0.0;

                if (title.isEmpty || targetAmount == null) {
                   ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a valid title and target amount')),
                    );
                  return;
                }

                final newGuestGoal = GuestGoal(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: title,
                  targetAmount: targetAmount,
                  savedAmount: savedAmount,
                );

                try {
                  await _storageService.addGoal(newGuestGoal);
                  _fetchGoals(); 

                  if(mounted) {
                    Navigator.of(context).pop();
                  }
                } catch (e) {
                   if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to save goal: $e')),
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
        title: const Text('My Goals (Guest)'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _guestGoals.isEmpty
            ? const Center(child: Text('No goals added yet.'))
            : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _guestGoals.length,
              itemBuilder: (context, index) {
                final guestGoal = _guestGoals[index];
                double saved = guestGoal.savedAmount;
                double target = guestGoal.targetAmount;
                double progress = (target > 0) ? saved / target : 0.0;

                return Card(
                  elevation: 2.0,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          guestGoal.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('Saved ₹$saved of ₹$target'),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.grey[300],
                          color: progress >= 1 ? Colors.blue : Colors.orange,
                          minHeight: 10,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddGuestGoalDialog,
        tooltip: 'Add Goal',
        child: const Icon(Icons.add),
      ),
    );
  }
}