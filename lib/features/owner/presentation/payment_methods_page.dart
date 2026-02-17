import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PaymentMethodsPage extends ConsumerStatefulWidget {
  const PaymentMethodsPage({super.key});

  @override
  ConsumerState<PaymentMethodsPage> createState() => _PaymentMethodsPageState();
}

class _PaymentMethodsPageState extends ConsumerState<PaymentMethodsPage> {
  // Mock data for now
  final List<Map<String, dynamic>> _methods = [
    {'type': 'Bank Account', 'details': 'HDFC Bank •••• 1234', 'isPrimary': true},
    {'type': 'UPI', 'details': 'user@okhdfcbank', 'isPrimary': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payout Methods"),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Add method functionality coming soon!")),
          );
        },
        label: const Text("Add Method"),
        icon: const Icon(Icons.add),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _methods.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final method = _methods[index];
          final isPrimary = method['isPrimary'] as bool;

          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isPrimary ? Colors.blue.withOpacity(0.5) : Colors.grey.withOpacity(0.2)),
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  method['type'] == 'UPI' ? Icons.qr_code : Icons.account_balance,
                  color: Theme.of(context).iconTheme.color,
                ),
              ),
              title: Text(method['type'], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(method['details']),
              trailing: isPrimary 
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text("PRIMARY", style: TextStyle(
                      color: Colors.blue, 
                      fontSize: 10, 
                      fontWeight: FontWeight.bold
                    )),
                  )
                : PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'primary', child: Text("Set as Primary")),
                      const PopupMenuItem(value: 'remove', child: Text("Remove", style: TextStyle(color: Colors.red))),
                    ],
                    onSelected: (val) {
                       ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Action: $val")),
                      );
                    },
                  ),
            ),
          );
        },
      ),
    );
  }
}
