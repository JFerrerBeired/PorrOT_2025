import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/contestant.dart';
import '../../domain/repositories/contestant_repository.dart';
import '../models/contestant_model.dart';

class ContestantRepositoryImpl implements ContestantRepository {
  final FirebaseFirestore _firestore;

  ContestantRepositoryImpl(this._firestore);

  @override
  Future<void> createContestant(Contestant contestant) async {
    final contestantModel = ContestantModel(
      contestantId:
          contestant.contestantId, // Will be null initially for new contestants
      name: contestant.name,
      photoUrl: contestant.photoUrl,
      status: contestant.status,
    );

    // If contestantId is null, auto-generate one using Firestore's document ID
    if (contestant.contestantId == null) {
      await _firestore
          .collection('contestants')
          .add(contestantModel.toFirestore());
    } else {
      await _firestore
          .collection('contestants')
          .doc(contestant.contestantId)
          .set(contestantModel.toFirestore());
    }
  }

  @override
  Future<List<Contestant>> getAllContestants() async {
    final snapshot = await _firestore.collection('contestants').get();
    return snapshot.docs
        .map((doc) => ContestantModel.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<Contestant> getContestantById(String id) async {
    final doc = await _firestore.collection('contestants').doc(id).get();
    return ContestantModel.fromFirestore(doc.data()!, doc.id);
  }

  @override
  Future<void> updateContestant(Contestant contestant) async {
    final contestantModel = ContestantModel(
      contestantId: contestant.contestantId,
      name: contestant.name,
      photoUrl: contestant.photoUrl,
      status: contestant.status,
    );

    // Use the existing ID if available
    if (contestant.contestantId != null) {
      await _firestore
          .collection('contestants')
          .doc(contestant.contestantId)
          .update(contestantModel.toFirestore());
    }
  }

  @override
  Future<void> updateContestantStatus(
    String contestantId,
    ContestantStatus newStatus,
  ) async {
    await _firestore.collection('contestants').doc(contestantId).update({
      'status': newStatus.toString().split('.').last,
    });
  }
}
