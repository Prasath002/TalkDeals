import 'package:cloud_firestore/cloud_firestore.dart';

class Customer {
  final String id, name, email, phone, role;
  final DateTime? lastSeen;

  Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.lastSeen,
  });

  factory Customer.fromDoc(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return Customer(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      role: data['role'] ?? 'User',
      lastSeen: (data['lastSeen'] as Timestamp?)?.toDate(),
    );
  }

  /// Derived presence: active if seen in last 5 min
  bool get isActive =>
      lastSeen != null && DateTime.now().difference(lastSeen!).inMinutes < 5;
}
