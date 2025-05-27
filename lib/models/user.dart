import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String? id;
  final String name;
  final String email;
  final String phone;
  final String nif;
  final DateTime registrationDate;
  final String role;
  final String status;

  const User({
    // Constructor const
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.nif,
    required this.registrationDate,
    required this.role,
    required this.status,
  });

  factory User.fromMap(Map<String, dynamic> map, {String? documentId}) {
    return User(
      id: documentId,
      name: map['name'] as String? ?? 'Usuario sin nombre',
      email: map['email'] as String? ?? 'Correo no especificado',
      phone: map['phone'] as String? ?? 'Teléfono no especificado',
      nif: map['nif'] as String? ?? 'NIF no especificado',
      registrationDate:
          map['registrationDate'] is Timestamp
              ? (map['registrationDate'] as Timestamp).toDate()
              : DateTime.now(),
      role: map['role'] as String? ?? 'user', // Rol por defecto 'user'
      status:
          map['status'] as String? ?? 'Activo', // Estado por defecto 'Activo'
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'nif': nif,
      'registrationDate': Timestamp.fromDate(registrationDate),
      'role': role,
      'status': status,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? nif,
    DateTime? registrationDate,
    String? role,
    String? status,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      nif: nif ?? this.nif,
      registrationDate: registrationDate ?? this.registrationDate,
      role: role ?? this.role,
      status: status ?? this.status,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, role: $role, status: $status)';
  }
}
