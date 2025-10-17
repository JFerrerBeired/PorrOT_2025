import '../entities/gala.dart';
import '../entities/prediction.dart';

class ScoreCalculator {
  // --- Scoring Constants ---
  static const int favoriteHit = 10;
  static const int eliminatedHit = 10;
  static const List<int> nomineeHits = [5, 15, 30, 50]; // 1, 2, 3, or 4 hits
  static const int savedByProfessorsBonus = 5;
  static const int savedByPeersBonus = 5;

  /// Calculates the score for a single prediction based on the official gala results.
  ///
  /// Returns a map containing the total score and a breakdown of points.
  Map<String, dynamic> calculateScore(Prediction prediction, Gala gala) {
    int totalScore = 0;
    final scoreBreakdown = <String, dynamic>{};

    // --- Favorite Score ---
    if (prediction.favoriteId == gala.results['favoriteId']) {
      totalScore += favoriteHit;
      scoreBreakdown['favorite'] = favoriteHit;
    }

    // --- Eliminated Score ---
    if (prediction.eliminatedId == gala.results['eliminatedId']) {
      totalScore += eliminatedHit;
      scoreBreakdown['eliminated'] = eliminatedHit;
    }

    // --- Nominee Proposal Score ---
    final correctNominees = prediction.nomineeProposalIds
            ?.where((id) =>
                (gala.results['nomineeProposalIds'] as List).contains(id))
            .length ??
        0;

    if (correctNominees > 0) {
      final nomineeScore = nomineeHits[correctNominees - 1];
      totalScore += nomineeScore;
      scoreBreakdown['nominee_base'] = nomineeScore;
      scoreBreakdown['nominee_hits'] = correctNominees;
    }

    // --- Saved by Professors Bonus ---
    if (prediction.savedByProfessorsId != null &&
        prediction.savedByProfessorsId == gala.results['savedByProfessorsId']) {
      totalScore += savedByProfessorsBonus;
      scoreBreakdown['saved_by_professors'] = savedByProfessorsBonus;
    }

    // --- Saved by Peers Bonus ---
    if (prediction.savedByPeersId != null &&
        prediction.savedByPeersId == gala.results['savedByPeersId']) {
      totalScore += savedByPeersBonus;
      scoreBreakdown['saved_by_peers'] = savedByPeersBonus;
    }

    return {
      'score': totalScore,
      'scoreBreakdown': scoreBreakdown,
    };
  }
}