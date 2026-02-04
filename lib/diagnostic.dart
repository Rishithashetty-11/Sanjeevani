import 'package:flutter/material.dart';
import 'package:sanjeevani/api_service.dart';
import 'package:sanjeevani/models/cart_item.dart';

class DiagnosticCenterListScreen extends StatefulWidget {
  const DiagnosticCenterListScreen({super.key});

  @override
  State<DiagnosticCenterListScreen> createState() =>
      _DiagnosticCenterListScreenState();
}

class _DiagnosticCenterListScreenState
    extends State<DiagnosticCenterListScreen> {
  final List<DiagnosticCenter> diagnosticCenters = [
    DiagnosticCenter(
      name: 'City Diagnostics',
      address: '789 Oak Street',
      distance: 3.1,
      tests: [
        DiagnosticTest(name: 'Blood Test', price: 50.0),
        DiagnosticTest(name: 'X-Ray', price: 120.0),
        DiagnosticTest(name: 'MRI Scan', price: 500.0),
      ],
    ),
    DiagnosticCenter(
      name: 'Central Imaging',
      address: '101 Pine Avenue',
      distance: 4.5,
      tests: [
        DiagnosticTest(name: 'CT Scan', price: 450.0),
        DiagnosticTest(name: 'Ultrasound', price: 80.0),
        DiagnosticTest(name: 'ECG', price: 60.0),
      ],
    ),
  ];

  final List<CartItem> _cart = [];

  void _addToCart(DiagnosticTest test, DiagnosticCenter center) {
    setState(() {
      for (var item in _cart) {
        if (item.test.name == test.name && item.center.name == center.name) {
          item.quantity++;
          return;
        }
      }
      _cart.add(CartItem(test: test, center: center));
    });
  }

  void _showAppointmentDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Book Appointment'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Your Name'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await ApiService.bookAppointment(
                  name: nameController.text,
                  phone: phoneController.text,
                  date: DateTime.now(),
                  cartItems: _cart,
                );
                Navigator.of(context).pop();
                setState(() {
                  _cart.clear();
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Appointment booked successfully!')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to book appointment: $e')),
                );
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Diagnostic Centers'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: _cart.isEmpty ? null : _showAppointmentDialog,
              ),
              if (_cart.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      _cart.length.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: diagnosticCenters.length,
        itemBuilder: (context, index) {
          final center = diagnosticCenters[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ExpansionTile(
              title: Text(center.name),
              subtitle: Text(
                '${center.address}\n${center.distance.toStringAsFixed(1)} km away',
              ),
              children: center.tests.map((test) {
                return ListTile(
                  title: Text(test.name),
                  subtitle: Text('\$${test.price.toStringAsFixed(2)}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.add_shopping_cart),
                    onPressed: () => _addToCart(test, center),
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}