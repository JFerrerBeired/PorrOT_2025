import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/prediction.dart';
import '../../domain/repositories/prediction_repository.dart';
import '../models/prediction_model.dart';

class PredictionRepositoryImpl implements PredictionRepository {
  final FirebaseFirestore _firestore;

  PredictionRepositoryImpl(this._firestore);

  @override
  Future<void> savePrediction(Prediction prediction) async {
    final predictionModel = PredictionModel(
      userId: prediction.userId,
      galaId: prediction.galaId,
      favoriteId: prediction.favoriteId,
      eliminatedId: prediction.eliminatedId,
      nomineeProposalIds: prediction.nomineeProposalIds,
      savedByProfessorsId: prediction.savedByProfessorsId,
      savedByPeersId: prediction.savedByPeersId,
      score: prediction.score,
      scoreBreakdown: prediction.scoreBreakdown,
    );
    // Create a unique ID for the prediction based on userId and galaId
    final predictionId = '${prediction.userId}_${prediction.galaId}';
    await _firestore
        .collection('predictions')
        .doc(predictionId)
        .set(predictionModel.toFirestore());
  }

  @override
  Future<Prediction?> getPredictionForGala(String userId, String galaId) async {
    final predictionId = '${userId}_$galaId';
    final doc = await _firestore
        .collection('predictions')
        .doc(predictionId)
        .get();
    if (doc.exists) {
      return PredictionModel.fromFirestore(doc.data()!, doc.id);
    }
    return null;
  }

  @override
  Future<List<Prediction>> getPredictionsForGala(String galaId) async {
    final snapshot = await _firestore
        .collection('predictions')
        .where('galaId', isEqualTo: galaId)
        .get();
    return snapshot.docs
        .map((doc) => PredictionModel.fromFirestore(doc.data(), doc.id))
        .toList();
  }
}
