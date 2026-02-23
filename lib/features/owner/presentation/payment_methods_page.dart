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

  void _addMockAccount() {
    setState(() {
      _methods.add({
        'type': 'Bank Account',
        'details': 'Standard Chartered •••• 5678',
        'isPrimary': false,
      });
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Mock bank account added successfully!"),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _setPrimary(int index) {
    setState(() {
      for (int i = 0; i < _methods.length; i++) {
        _methods[i]['isPrimary'] = (i == index);
      }
    });
  }

  void _removeMethod(int index) {
    if (_methods[index]['isPrimary'] && _methods.length > 1) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cannot remove primary method. Set another primary first.")),
      );
      return;
    }
    setState(() {
      _methods.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payout Methods"),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addMockAccount,
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
          final colorScheme = Theme.of(context).colorScheme;

          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isPrimary ? colorScheme.primary.withOpacity(0.5) : colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  method['type'] == 'UPI' ? Icons.qr_code : Icons.account_balance,
                  color: colorScheme.primary,
                ),
              ),
              title: Text(method['type'], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(method['details']),
              trailing: isPrimary 
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text("PRIMARY", style: TextStyle(
                      color: colorScheme.onPrimaryContainer, 
                      fontSize: 10, 
                      fontWeight: FontWeight.bold
                    )),
                  )
                : PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'primary', child: Text("Set as Primary")),
                      PopupMenuItem(
                        value: 'remove', 
                        child: Text("Remove", style: TextStyle(color: colorScheme.error)),
                      ),
                    ],
                    onSelected: (val) {
                       if (val == 'primary') {
                         _setPrimary(index);
                       } else if (val == 'remove') {
                         _removeMethod(index);
                       }
                    },
                  ),
            ),
          );
        },
      ),
    );
  }
}
