// Remove the commented out import
import 'package:flutter/material.dart';
import 'package:sanjeevani/api_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sanjeevani',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sanjeevani'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BloodBankListScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.bloodtype, color: Colors.red),
              label: const Text('Find Blood Banks'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DiagnosticCenterListScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.local_hospital, color: Colors.blue),
              label: const Text('Find Diagnostic Centers'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BloodBank {
  final String name;
  final String address;
  final double distance;
  final Map<String, int> bloodInventory;

  BloodBank({
    required this.name,
    required this.address,
    required this.distance,
    required this.bloodInventory,
  });
}

class BloodBankListScreen extends StatefulWidget {
  const BloodBankListScreen({super.key});

  @override
  State<BloodBankListScreen> createState() => _BloodBankListScreenState();
}

class _BloodBankListScreenState extends State<BloodBankListScreen> {
  // Dummy data - Replace with actual API calls and location services
  final List<BloodBank> bloodBanks = [
    BloodBank(
      name: 'City Blood Bank',
      address: '123 Main Street',
      distance: 1.2,
      bloodInventory: {
        'A+': 10,
        'A-': 5,
        'B+': 8,
        'B-': 3,
        'O+': 15,
        'O-': 7,
        'AB+': 4,
        'AB-': 2,
      },
    ),
    BloodBank(
      name: 'Central Blood Center',
      address: '456 Park Avenue',
      distance: 2.5,
      bloodInventory: {
        'A+': 12,
        'A-': 6,
        'B+': 9,
        'B-': 4,
        'O+': 18,
        'O-': 8,
        'AB+': 5,
        'AB-': 3,
      },
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Blood Banks'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView.builder(
        itemCount: bloodBanks.length,
        itemBuilder: (context, index) {
          final bloodBank = bloodBanks[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(bloodBank.name),
              subtitle: Text(
                '${bloodBank.address}\n${bloodBank.distance.toStringAsFixed(1)} km away',
              ),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) =>
                      BloodInventorySheet(bloodBank: bloodBank),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class BloodInventorySheet extends StatelessWidget {
  final BloodBank bloodBank;

  const BloodInventorySheet({super.key, required this.bloodBank});

  void _showRequestDialog(BuildContext context) {
    String? selectedBloodType;
    final unitsController = TextEditingController();
    final contactController = TextEditingController();
    final purposeController = TextEditingController();
  
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Blood'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Blood Type'),
                value: selectedBloodType,
                items: bloodBank.bloodInventory.keys.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? value) {
                  selectedBloodType = value;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: unitsController,
                decoration: const InputDecoration(
                  labelText: 'Units Required',
                  hintText: 'Enter number of units',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: contactController,
                decoration: const InputDecoration(
                  labelText: 'Contact Number',
                  hintText: 'Enter your phone number',
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: purposeController,
                decoration: const InputDecoration(
                  labelText: 'Purpose',
                  hintText: 'Brief reason for blood requirement',
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final success = await ApiService.sendBloodRequest(
                  name: 'Rishitha', // Replace with dynamic user input later
                  bloodType: selectedBloodType ?? 'O+',
                  units: int.tryParse(unitsController.text) ?? 1,
                  contact: contactController.text.isEmpty ? '9999999999' : contactController.text,
                  purpose: purposeController.text.isEmpty ? 'Emergency' : purposeController.text,
                );
  
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success
                        ? 'Blood request sent successfully!'
                        : 'Failed to send request'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Submit Request'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            bloodBank.name,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16.0),
          Wrap(
            spacing: 16.0,
            runSpacing: 8.0,
            children: bloodBank.bloodInventory.entries.map((entry) {
              return Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  children: [
                    Text(
                      entry.key,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('${entry.value} units'),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24.0),
          ElevatedButton.icon(
            onPressed: () => _showRequestDialog(context),
            icon: const Icon(Icons.local_hospital),
            label: const Text('Request Blood'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class DiagnosticCenter {
  final String name;
  final String address;
  final double distance;
  final List<DiagnosticTest> tests;

  DiagnosticCenter({
    required this.name,
    required this.address,
    required this.distance,
    required this.tests,
  });
}

class DiagnosticTest {
  final String name;
  final String description;
  final double price;

  DiagnosticTest({
    required this.name,
    required this.description,
    required this.price,
  });
}

class CartItem {
  final DiagnosticTest test;
  final DiagnosticCenter center;

  CartItem({required this.test, required this.center});
}

class HomePages extends StatelessWidget {
  const HomePages({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sanjeevani'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BloodBankListScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.bloodtype, color: Colors.red),
              label: const Text('Find Blood Banks'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DiagnosticCenterListScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.local_hospital, color: Colors.blue),
              label: const Text('Find Diagnostic Centers'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DiagnosticCenterListScreen extends StatefulWidget {
  const DiagnosticCenterListScreen({super.key});

  @override
  State<DiagnosticCenterListScreen> createState() =>
      _DiagnosticCenterListScreenState();
}

class _DiagnosticCenterListScreenState
    extends State<DiagnosticCenterListScreen> {
  final List<CartItem> _cart = [];

  // Dummy data - Replace with actual API calls
  final List<DiagnosticCenter> centers = [
    DiagnosticCenter(
      name: 'City Diagnostics',
      address: '123 Health Street',
      distance: 1.5,
      tests: [
        DiagnosticTest(
          name: 'Complete Blood Count',
          description: 'Measures different components of blood',
          price: 500.0,
        ),
        DiagnosticTest(
          name: 'Blood Sugar Test',
          description: 'Measures glucose levels in blood',
          price: 300.0,
        ),
        DiagnosticTest(
          name: 'Thyroid Profile',
          description: 'Comprehensive thyroid function test',
          price: 800.0,
        ),
      ],
    ),
    DiagnosticCenter(
      name: 'HealthFirst Labs',
      address: '456 Medical Avenue',
      distance: 2.8,
      tests: [
        DiagnosticTest(
          name: 'Lipid Profile',
          description: 'Cholesterol and triglycerides test',
          price: 600.0,
        ),
        DiagnosticTest(
          name: 'Liver Function Test',
          description: 'Comprehensive liver health assessment',
          price: 700.0,
        ),
      ],
    ),
  ];

  void _showTestDetails(DiagnosticCenter center) {
    showModalBottomSheet(
      context: context,
      builder: (context) => TestListSheet(
        center: center,
        onAddToCart: (test) {
          setState(() {
            _cart.add(CartItem(test: test, center: center));
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${test.name} added to cart'),
              action: SnackBarAction(
                label: 'View Cart',
                onPressed: () => _showCart(),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showCart() {
    showModalBottomSheet(
      context: context,
      builder: (context) => CartSheet(
        cartItems: _cart,
        onBookAppointment: () {
          Navigator.pop(context);
          _showAppointmentDialog();
        },
      ),
    );
  }

  void _showAppointmentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Book Appointment'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CalendarDatePicker(
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 30)),
                onDateChanged: (date) {},
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'Enter your full name',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  hintText: 'Enter your contact number',
                ),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Here you would implement the actual appointment booking
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Appointment booked successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Confirm Booking'),
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
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: _cart.isEmpty ? null : _showCart,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: centers.length,
        itemBuilder: (context, index) {
          final center = centers[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(center.name),
              subtitle: Text(
                '${center.address}\n${center.distance.toStringAsFixed(1)} km away\n${center.tests.length} tests available',
              ),
              onTap: () => _showTestDetails(center),
            ),
          );
        },
      ),
    );
  }
}

class TestListSheet extends StatelessWidget {
  final DiagnosticCenter center;
  final Function(DiagnosticTest) onAddToCart;

  const TestListSheet({
    super.key,
    required this.center,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(center.name, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16.0),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: ListView.builder(
              itemCount: center.tests.length,
              itemBuilder: (context, index) {
                final test = center.tests[index];
                return Card(
                  child: ListTile(
                    title: Text(test.name),
                    subtitle: Text(test.description),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '₹${test.price.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        ElevatedButton(
                          onPressed: () => onAddToCart(test),
                          child: const Text('Add to Cart'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CartSheet extends StatelessWidget {
  final List<CartItem> cartItems;
  final VoidCallback onBookAppointment;

  const CartSheet({
    super.key,
    required this.cartItems,
    required this.onBookAppointment,
  });

  double get totalAmount {
    return cartItems.fold(0, (sum, item) => sum + item.test.price);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Your Cart', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16.0),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            child: ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return ListTile(
                  title: Text(item.test.name),
                  subtitle: Text(item.center.name),
                  trailing: Text('₹${item.test.price.toStringAsFixed(2)}'),
                );
              },
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total:', style: Theme.of(context).textTheme.titleLarge),
                Text(
                  '₹${totalAmount.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onBookAppointment,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text('Book Appointment Now'),
          ),
        ],
      ),
    );
  }
}
