class Prediction {
  final String userId;
  final String galaId;
  final String favoriteId;
  final String eliminatedId;
  final List<String> nomineeProposalIds;
  final String savedByProfessorsId;
  final String savedByPeersId;
  final int? score;
  final Map<String, dynamic>? scoreBreakdown;

  Prediction({
    required this.userId,
    required this.galaId,
    required this.favoriteId,
    required this.eliminatedId,
    required this.nomineeProposalIds,
    required this.savedByProfessorsId,
    required this.savedByPeersId,
    this.score,
    this.scoreBreakdown,
  });
}
