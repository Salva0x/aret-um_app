class Space {
  final String? id;
  final String name;
  final int capacity;
  final String status;

  const Space({
    // Constructor const
    this.id,
    required this.name,
    required this.capacity,
    required this.status,
  });

  factory Space.fromMap(Map<String, dynamic> map, {String? documentId}) {
    return Space(
      id: documentId,
      name: map['name'] as String? ?? 'Sala sin nombre',
      capacity: (map['capacity'] as num?)?.toInt() ?? 0,
      status: map['status'] as String? ?? 'Estado desconocido',
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'capacity': capacity, 'status': status};
  }

  Space copyWith({String? id, String? name, int? capacity, String? status}) {
    return Space(
      id: id ?? this.id,
      name: name ?? this.name,
      capacity: capacity ?? this.capacity,
      status: status ?? this.status,
    );
  }

  @override
  String toString() {
    return 'Space(id: $id, name: $name, capacity: $capacity, status: $status)';
  }
}
