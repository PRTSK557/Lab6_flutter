import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../widgets/category_card.dart';
import 'category_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Expense> _expenses = [];
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  ExpenseCategory _selectedCategory = ExpenseCategory.food;

  @override
  void initState() {
    super.initState();
    // Тестові дані згідно зі скріншотом
    _expenses.addAll([
      Expense(id: 1, title: 'Lunch', amount: 25.0, category: ExpenseCategory.food, date: DateTime(2026, 4, 14)),
      Expense(id: 2, title: 'Uber ride', amount: 15.5, category: ExpenseCategory.transport, date: DateTime(2026, 4, 14)),
      Expense(id: 3, title: 'New sneakers', amount: 89.99, category: ExpenseCategory.shopping, date: DateTime(2026, 4, 13)),
    ]);
  }

  double get _totalExpenses => _expenses.fold(0.0, (sum, item) => sum + item.amount);

  void _showAddExpenseDialog() {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Center(child: Text('Add Expense', style: TextStyle(fontWeight: FontWeight.bold))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('TITLE', style: TextStyle(fontSize: 12, color: Colors.orange, fontWeight: FontWeight.bold)),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Lunch at cafe',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.orange)),
                ),
              ),
              const SizedBox(height: 16),
              const Text('AMOUNT', style: TextStyle(fontSize: 12, color: Colors.orange, fontWeight: FontWeight.bold)),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixText: '\$ ',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 16),
              const Text('CATEGORY', style: TextStyle(fontSize: 12, color: Colors.orange, fontWeight: FontWeight.bold)),
              DropdownButtonFormField<ExpenseCategory>(
                value: _selectedCategory,
                decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                items: ExpenseCategory.values.map((cat) => DropdownMenuItem(
                  value: cat,
                  child: Row(children: [Icon(cat.icon, size: 18, color: Colors.orange), const SizedBox(width: 8), Text(cat.name)]),
                )).toList(),
                onChanged: (val) => setDialogState(() => _selectedCategory = val!),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _addExpense,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Add', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _addExpense() {
    final title = _titleController.text;
    final amount = double.tryParse(_amountController.text);
    if (title.isEmpty || amount == null || amount <= 0) return;
    setState(() {
      _expenses.add(Expense(id: DateTime.now().millisecondsSinceEpoch, title: title, amount: amount, category: _selectedCategory, date: DateTime.now()));
    });
    _titleController.clear(); _amountController.clear();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: const Text('My Expenses', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orange,
        elevation: 0,
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.add_circle, color: Colors.white, size: 30))],
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Card
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TOTAL THIS MONTH', style: TextStyle(color: Colors.orange[300], fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('\$${_totalExpenses.toStringAsFixed(2)}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF8B4513))),
                  ],
                ),
              ),
            ),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Categories', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
            const SizedBox(height: 8),
            // Categories Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: ExpenseCategory.values.map((cat) => CategoryCard(
                  category: cat,
                  totalAmount: _expenses.where((e) => e.category == cat).fold(0.0, (sum, e) => sum + e.amount),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CategoryDetailsScreen(category: cat, expenses: _expenses))).then((_) => setState(() {})),
                )).toList(),
              ),
            ),
            const Padding(padding: EdgeInsets.all(16), child: Text('Recent Transactions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
            // Transactions List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _expenses.length,
              itemBuilder: (ctx, i) {
                final exp = _expenses[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      leading: Icon(exp.category.icon, color: Colors.orange[200]),
                      title: Text(exp.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${exp.date.day}/${exp.date.month}/${exp.date.year}', style: const TextStyle(fontSize: 12)),
                      trailing: Text('-\$${exp.amount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddExpenseDialog,
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}