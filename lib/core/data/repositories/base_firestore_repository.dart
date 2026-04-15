import 'package:cloud_firestore/cloud_firestore.dart';

typedef FromFirestore<T> = T Function(Map<String, dynamic> data, String id);
typedef ToFirestore<T> = Map<String, dynamic> Function(T item);

abstract class BaseFirestoreRepository<T> {
  final FirebaseFirestore firestore;
  final String collectionPath;
  final FromFirestore<T> fromFirestore;
  final ToFirestore<T> toFirestore;

  BaseFirestoreRepository({
    FirebaseFirestore? firestore,
    required this.collectionPath,
    required this.fromFirestore,
    required this.toFirestore,
  }) : firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get collection =>
      firestore.collection(collectionPath);

  Stream<List<T>> streamAll() {
    return collection.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => fromFirestore(doc.data(), doc.id)).toList());
  }

  Future<List<T>> getAll() async {
    final snapshot = await collection.get();
    return snapshot.docs.map((doc) => fromFirestore(doc.data(), doc.id)).toList();
  }

  Future<T?> getById(String id) async {
    final doc = await collection.doc(id).get();
    if (!doc.exists) return null;
    return fromFirestore(doc.data()!, doc.id);
  }

  Future<void> create(T item, {String? customId}) async {
    final data = toFirestore(item);
    await collection.doc(customId).set(data);
  }

  Future<void> update(String id, T item) async {
    final data = toFirestore(item);
    await collection.doc(id).update(data);
  }

  Future<void> delete(String id) async {
    await collection.doc(id).delete();
  }

  Future<bool> exists(String id) async {
    final doc = await collection.doc(id).get();
    return doc.exists;
  }
}
