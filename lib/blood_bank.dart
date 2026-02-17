import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sanjeevani/api_service.dart'; // <-- ADDED IMPORT

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
      // The resizeToAvoidBottomInset property is true by default, but explicitly setting it
      // ensures the UI resizes to accommodate the keyboard, preventing overflow.
      resizeToAvoidBottomInset: true,
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
                  // This allows the bottom sheet to take up the full screen height if needed,
                  // which is crucial for preventing overflow when the keyboard appears.
                  isScrollControlled: true,
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
    final _formKey = GlobalKey<FormState>();
    String? selectedBloodType;
    String? selectedUrgency;
    final nameController = TextEditingController();
    final unitsController = TextEditingController();
    final contactController = TextEditingController();
    final hospitalController = TextEditingController();
    final cityController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Blood'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Your Name'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter your name' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Urgency'),
                  value: selectedUrgency,
                  items: ['Low', 'Medium', 'High'].map((String level) {
                    return DropdownMenuItem<String>(
                      value: level,
                      child: Text(level),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    selectedUrgency = value;
                  },
                  validator: (value) =>
                      value == null ? 'Please select urgency' : null,
                ),
                const SizedBox(height: 16),
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
                  validator: (value) =>
                      value == null ? 'Please select a blood type' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: unitsController,
                  decoration: const InputDecoration(
                    labelText: 'Units Required',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) => value!.isEmpty
                      ? 'Please enter the number of units'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: contactController,
                  decoration: const InputDecoration(
                    labelText: 'Contact Number',
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) => value!.isEmpty
                      ? 'Please enter your contact number'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: hospitalController,
                  decoration: const InputDecoration(labelText: 'Hospital'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter the hospital name' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: cityController,
                  decoration: const InputDecoration(labelText: 'City'),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter the city' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                try {
                  Position position = await getUserLocation();
                  await ApiService.sendBloodRequest(
                    name: nameController.text,
                    bloodType: selectedBloodType!,
                    units: int.parse(unitsController.text),
                    contact: contactController.text,
                    urgency: selectedUrgency!,
                    latitude: position.latitude,
                    longitude: position.longitude,
                  );
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Blood request sent successfully!'),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to send request: $e')),
                  );
                }
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
    // By placing SingleChildScrollView as the root and Padding inside, we ensure
    // that the entire content is scrollable, preventing overflow issues.
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              bloodBank.name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            const Text('Available Blood Units:'),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 2,
              ),
              itemCount: bloodBank.bloodInventory.length,
              itemBuilder: (context, index) {
                String bloodType = bloodBank.bloodInventory.keys.elementAt(
                  index,
                );
                int units = bloodBank.bloodInventory.values.elementAt(index);
                return Card(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        bloodType,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('$units units'),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: () => _showRequestDialog(context),
                child: const Text('Request Blood'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
