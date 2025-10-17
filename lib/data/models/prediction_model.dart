import '../../domain/entities/prediction.dart';

class PredictionModel extends Prediction {
  PredictionModel({
    required super.userId,
    required super.galaId,
    required super.favoriteId,
    required super.eliminatedId,
    required super.nomineeProposalIds,
    required super.savedByProfessorsId,
    required super.savedByPeersId,
    super.score,
    super.scoreBreakdown,
  });

  factory PredictionModel.fromFirestore(
    Map<String, dynamic> data,
    String documentId,
  ) {
    return PredictionModel(
      userId: data['userId'],
      galaId: data['galaId'],
      favoriteId: data['favoriteId'],
      eliminatedId: data['eliminatedId'],
      nomineeProposalIds: List<String>.from(data['nomineeProposalIds']),
      savedByProfessorsId: data['savedByProfessorsId'],
      savedByPeersId: data['savedByPeersId'],
      score: data['score'],
      scoreBreakdown: data['scoreBreakdown'] != null
          ? Map<String, dynamic>.from(data['scoreBreakdown'])
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'galaId': galaId,
      'favoriteId': favoriteId,
      'eliminatedId': eliminatedId,
      'nomineeProposalIds': nomineeProposalIds,
      'savedByProfessorsId': savedByProfessorsId,
      'savedByPeersId': savedByPeersId,
      'score': score,
      'scoreBreakdown': scoreBreakdown,
    };
  }
}
