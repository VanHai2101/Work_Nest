import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/data/repositories/base_firestore_repository.dart';
import '../models/index.dart';
import '../../domain/entities/index.dart';
import '../../domain/repositories/index.dart';

class FirebaseProjectRepository extends BaseFirestoreRepository<ProjectEntity>
    implements ProjectRepository {
  FirebaseProjectRepository({super.firestore})
      : super(
          collectionPath: 'projects',
          fromFirestore: (data, id) => ProjectModel.fromJson(data, id: id).toEntity(),
          toFirestore: (item) => ProjectModel.fromEntity(item).toJson(),
        );

  @override
  Stream<List<ProjectEntity>> getProjects() {
    return streamAll();
  }

  @override
  Stream<List<ProjectEntity>> getProjectsByMember(String uid) {
    return collection
        .where('memberIds', arrayContains: uid)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => fromFirestore(doc.data(), doc.id))
            .toList());
  }

  @override
  Future<void> createProject(ProjectEntity project) async {
    await create(project, customId: project.id.isEmpty ? null : project.id);
  }

  @override
  Future<void> updateProject(ProjectEntity project) async {
    // Security rules allow partial updates for members/owners but specify notChanging(['ownerId', 'createdAt'])
    // Our BaseFirestoreRepository.update uses collection.doc(id).update(data), which is perfect for partial updates
    // if we pass exactly what needs to be changed.
    // However, our model's toJson() sends EVERYTHING.
    // For simplicity and matching the model's structure, we can use set(merge: true) inside update() if we want.
    // Let's stick to the base class's implementation and assume the caller ensures valid data.
    await update(project.id, project);
  }

  @override
  Future<void> deleteProject(String projectId) async {
    await delete(projectId);
  }

  @override
  Future<ProjectEntity?> getProjectById(String projectId) async {
    return getById(projectId);
  }
}
