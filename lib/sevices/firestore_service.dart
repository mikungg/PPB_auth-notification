import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  //get collection
  final CollectionReference notes = FirebaseFirestore.instance.collection(
    'notes',
  );

  //create
  Future<void> addNote(String title, String note) {
    return notes.add({
      'title': title,
      'note': note,
      'timestamp': Timestamp.now(),
    });
  }

  //read
  Stream<QuerySnapshot> getNotes() {
    final noteStream = notes.orderBy('timestamp', descending: true).snapshots();
    return noteStream;
  }

  //update
  Future<void> updateNote(String docID, String title, String newNote) {
    return notes.doc(docID).update({
      'title': title,
      'note': newNote,
      'timestamp': Timestamp.now(),
    });
  }

  //delete

  Future<void> deleteNote(String docID) {
    return notes.doc(docID).delete();
  }
}
