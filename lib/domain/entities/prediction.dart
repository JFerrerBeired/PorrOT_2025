class Prediction {
  final String userId;
  final String galaId;
  final String? favoriteId; // Made nullable
  final String? eliminatedId; // Made nullable
  final List<String>? nomineeProposalIds; // Made nullable
  final String? savedByProfessorsId; // Made nullable
  final String? savedByPeersId; // Made nullable
  final int? score;
  final Map<String, dynamic>? scoreBreakdown;

  Prediction({
    required this.userId,
    required this.galaId,
    this.favoriteId, // No longer required
    this.eliminatedId, // No longer required
    this.nomineeProposalIds, // No longer required
    this.savedByProfessorsId, // No longer required
    this.savedByPeersId, // No longer required
    this.score,
    this.scoreBreakdown,
  });
}
