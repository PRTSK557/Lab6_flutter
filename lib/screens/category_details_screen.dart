import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../models/category.dart';

class CategoryDetailsScreen extends StatelessWidget {
  final ExpenseCategory category;
  final List<Expense> expenses;

  const CategoryDetailsScreen({super.key, required this.category, required this.expenses});

  @override
  Widget build(BuildContext context) {
    final filtered = expenses.where((e) => e.category == category).toList();
    final total = filtered.fold(0.0, (sum, e) => sum + e.amount);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: Text(category.name, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.orange,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40),
            color: const Color(0xFFFFF5E6),
            child: Column(
              children: [
                Icon(category.icon, size: 48, color: Colors.orange),
                const SizedBox(height: 10),
                Text('\$${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.orange)),
                Text('${filtered.length} transactions', style: const TextStyle(color: Colors.orange)),
              ],
            ),
          ),
          const Padding(padding: EdgeInsets.all(16), child: Align(alignment: Alignment.centerLeft, child: Text('All Transactions', style: TextStyle(fontWeight: FontWeight.bold)))),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (ctx, i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    title: Text(filtered[i].title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${filtered[i].date.day}/${filtered[i].date.month}/${filtered[i].date.year}'),
                    trailing: Text('-\$${filtered[i].amount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}