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
      contestantId: contestant.contestantId,
      name: contestant.name,
      photoUrl: contestant.photoUrl,
      status: contestant.status,
    );
    await _firestore
        .collection('contestants')
        .doc(contestant.contestantId)
        .set(contestantModel.toFirestore());
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
    await _firestore
        .collection('contestants')
        .doc(contestant.contestantId)
        .update(contestantModel.toFirestore());
  }
}
