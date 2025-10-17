import '../../domain/entities/prediction.dart';

class PredictionModel extends Prediction {
  PredictionModel({
    required super.userId,
    required super.galaId,
    super.favoriteId, // No longer required
    super.eliminatedId, // No longer required
    super.nomineeProposalIds, // No longer required
    super.savedByProfessorsId, // No longer required
    super.savedByPeersId, // No longer required
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
      favoriteId: data['favoriteId'] as String?,
      eliminatedId: data['eliminatedId'] as String?,
      nomineeProposalIds: (data['nomineeProposalIds'] as List?)
          ?.map((e) => e as String)
          .toList(),
      savedByProfessorsId: data['savedByProfessorsId'] as String?,
      savedByPeersId: data['savedByPeersId'] as String?,
      score: data['score'],
      scoreBreakdown: data['scoreBreakdown'] != null
          ? Map<String, dynamic>.from(data['scoreBreakdown'])
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    final Map<String, dynamic> data = {'userId': userId, 'galaId': galaId};
    if (favoriteId != null) data['favoriteId'] = favoriteId;
    if (eliminatedId != null) data['eliminatedId'] = eliminatedId;
    if (nomineeProposalIds != null) {
      data['nomineeProposalIds'] = nomineeProposalIds;
    }
    if (savedByProfessorsId != null) {
      data['savedByProfessorsId'] = savedByProfessorsId;
    }
    if (savedByPeersId != null) data['savedByPeersId'] = savedByPeersId;
    if (score != null) data['score'] = score;
    if (scoreBreakdown != null) data['scoreBreakdown'] = scoreBreakdown;
    return data;
  }
}
