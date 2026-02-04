class DiagnosticTest {
  final String name;
  final double price;

  DiagnosticTest({required this.name, required this.price});
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

class CartItem {
  final DiagnosticTest test;
  final DiagnosticCenter center;
  int quantity;

  CartItem({
    required this.test,
    required this.center,
    this.quantity = 1,
  });
}