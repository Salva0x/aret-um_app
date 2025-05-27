import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String? id;
  final String title;
  final String description;
  final String location;
  final String taughtBy;
  final DateTime date;
  final String time;
  final int maxCapacity;
  final int availableSlots;

  const Event({
    // Constructor const
    this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.taughtBy,
    required this.date,
    required this.time,
    required this.maxCapacity,
    required this.availableSlots,
  });

  factory Event.fromMap(Map<String, dynamic> map, {String? documentId}) {
    return Event(
      id: documentId,
      title: map['title'] as String? ?? 'Evento sin título',
      description: map['description'] as String? ?? 'Sin descripción',
      location: map['location'] as String? ?? 'Ubicación no especificada',
      taughtBy: map['taughtBy'] as String? ?? 'Instructor no especificado',
      date:
          map['date'] is Timestamp
              ? (map['date'] as Timestamp).toDate()
              : DateTime.now(),
      time: map['time'] as String? ?? 'Hora no especificada',
      maxCapacity: (map['maxCapacity'] as num?)?.toInt() ?? 0,
      availableSlots: (map['availableSlots'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'location': location,
      'taughtBy': taughtBy,
      'date': Timestamp.fromDate(date),
      'time': time,
      'maxCapacity': maxCapacity,
      'availableSlots': availableSlots,
    };
  }

  Event copyWith({
    String? id,
    String? title,
    String? description,
    String? location,
    String? taughtBy,
    DateTime? date,
    String? time,
    int? maxCapacity,
    int? availableSlots,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      taughtBy: taughtBy ?? this.taughtBy,
      date: date ?? this.date,
      time: time ?? this.time,
      maxCapacity: maxCapacity ?? this.maxCapacity,
      availableSlots: availableSlots ?? this.availableSlots,
    );
  }

  @override
  String toString() {
    return 'Event(id: $id, title: $title, date: $date, time: $time, taughtBy: $taughtBy)';
  }
}
