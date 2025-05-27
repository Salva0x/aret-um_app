import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:areteum_app/models/event.dart';
import 'package:areteum_app/models/user.dart';
import 'package:areteum_app/models/space.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Obtener todos los eventos
  Future<List<Event>> getEvents() async {
    QuerySnapshot snapshot = await _db.collection('events').get();
    return snapshot.docs
        .map((doc) => Event.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // Obtener todos los usuarios
  Future<List<User>> getUsers() async {
    QuerySnapshot snapshot = await _db.collection('users').get();
    return snapshot.docs
        .map((doc) => User.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // Obtener todos los espacios
  Future<List<Space>> getSpaces() async {
    QuerySnapshot snapshot = await _db.collection('spaces').get();
    return snapshot.docs
        .map((doc) => Space.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> addEvent(Event event) async {
    await _db.collection('events').add(event.toMap());
  }

  Future<void> addUser(User user) async {
    await _db.collection('users').add(user.toMap());
  }

  Future<void> addSpace(Space space) async {
    await _db.collection('spaces').add(space.toMap());
  }

  Future<void> updateEvent(String eventId, Event event) async {
    await _db.collection('events').doc(eventId).update(event.toMap());
  }

  Future<void> deleteEvent(String eventId) async {
    await _db.collection('events').doc(eventId).delete();
  }

  Future<void> deleteUser(String userId) async {
    await _db.collection('users').doc(userId).delete();
  }

  Future<void> deleteSpace(String spaceId) async {
    await _db.collection('spaces').doc(spaceId).delete();
  }
}
