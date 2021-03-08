import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static final _db = FirebaseFirestore.instance;
  static final CollectionReference customerListColRef =
      _db.collection('customer_list');

  //returns streams of customer list to customerList streambuilder
  static Stream<QuerySnapshot> get customerList =>
      customerListColRef.orderBy('startDate', descending: true).snapshots();

  static Future<void> createNewCustomer(Map customerData, Map notesData) async {
    try {
      DocumentReference docRef = await customerListColRef.add(customerData);
      await docRef.collection('customer_notes').add(notesData);
    } catch (e) {
      print(e);
    }
  }

  static Stream<QuerySnapshot> customerNotesList(DocumentSnapshot document) {
    return document.reference
        .collection('customer_notes')
        .orderBy('date', descending: true)
        .snapshots();
  }

  static Future<void> addNewData(DocumentSnapshot snapshot, Map data) async {
    try {
      await snapshot.reference.collection('customer_notes').add(data);
    } catch (e) {
      print(e);
    }
  }

  static Stream<QuerySnapshot> filteredData(
      DocumentSnapshot document, Timestamp startDate, Timestamp endDate) {
    return document.reference
        .collection('customer_notes')
        .where('date',
            isLessThanOrEqualTo: endDate, isGreaterThanOrEqualTo: startDate)
        .orderBy('date', descending: true)
        .snapshots();
  }

  static Future<void> deleteDocument(DocumentReference docReference) async {
    try {
      await docReference.delete();
    } catch (e) {}
  }
}
