import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/gala.dart';
import '../../domain/repositories/gala_repository.dart';
import '../models/gala_model.dart';

class GalaRepositoryImpl implements GalaRepository {
  final FirebaseFirestore _firestore;

  GalaRepositoryImpl(this._firestore);

  @override
  Future<void> createGala(Gala gala) async {
    final galaModel = GalaModel(
      galaId: gala.galaId,
      galaNumber: gala.galaNumber,
      date: gala.date,
      nominatedContestants: gala.nominatedContestants,
      results: gala.results,
    );
    
    // If galaId is null, auto-generate one using Firestore's document ID
    if (gala.galaId == null) {
      await _firestore.collection('galas').add(galaModel.toFirestore());
    } else {
      await _firestore
          .collection('galas')
          .doc(gala.galaId)
          .set(galaModel.toFirestore());
    }
  }

  @override
  Future<List<Gala>> getAllGalas() async {
    final snapshot = await _firestore.collection('galas').get();
    return snapshot.docs
        .map((doc) => GalaModel.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<Gala?> getGalaById(String id) async {
    final doc = await _firestore.collection('galas').doc(id).get();
    if (doc.exists && doc.data() != null) {
      return GalaModel.fromFirestore(doc.data()!, doc.id);
    }
    return null;
  }

  @override
  Future<void> updateGala(Gala gala) async {
    final galaModel = GalaModel(
      galaId: gala.galaId,
      galaNumber: gala.galaNumber,
      date: gala.date,
      nominatedContestants: gala.nominatedContestants,
      results: gala.results,
    );
    
    // Use the existing ID if available
    if (gala.galaId != null) {
      await _firestore
          .collection('galas')
          .doc(gala.galaId)
          .update(galaModel.toFirestore());
    }
  }

  @override
  Future<void> updateGalaNominees(String galaId, List<String> nominatedContestantIds) async {
    await _firestore.collection('galas').doc(galaId).update({
      'nominatedContestants': nominatedContestantIds,
    });
  }
}
