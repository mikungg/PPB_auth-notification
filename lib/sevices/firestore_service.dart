import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirestoreService {
  //get collection
  final CollectionReference notes = FirebaseFirestore.instance.collection(
    'notes',
  );

  final CollectionReference reminder = FirebaseFirestore.instance.collection(
    'reminder',
  );

  //create reminder
  Future<void> addReminder(bool toggle, TimeOfDay time) {
    return reminder.add({
      'toggle': toggle,
      'time': {'hour': time.hour, 'minute': time.minute},
      'timestamp': Timestamp.now(),
    });
  }

  //read reminder
  Stream<QuerySnapshot> getReminder() {
    final reminderStream =
        reminder.orderBy('timestamp', descending: true).snapshots();
    return reminderStream;
  }

  //update reminder
  Future<void> updateReminder(String docID, bool toggle, TimeOfDay time) {
    return reminder.doc(docID).update({
      'toggle': toggle,
      'time': {'hour': time.hour, 'minute': time.minute},
      'timestamp': Timestamp.now(),
    });
  }

  //create note
  Future<void> addNote(String title, String note) {
    return notes.add({
      'title': title,
      'note': note,
      'timestamp': Timestamp.now(),
    });
  }

  //read notes
  Stream<QuerySnapshot> getNotes() {
    final noteStream = notes.orderBy('timestamp', descending: true).snapshots();
    return noteStream;
  }

  //update note
  Future<void> updateNote(String docID, String title, String newNote) {
    return notes.doc(docID).update({
      'title': title,
      'note': newNote,
      'timestamp': Timestamp.now(),
    });
  }

  //delete note
  Future<void> deleteNote(String docID) {
    return notes.doc(docID).delete();
  }
}
