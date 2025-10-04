enum ContestantStatus { active, nominated, eliminated, winner }

class Contestant {
  final String contestantId;
  final String name;
  final String photoUrl;
  final ContestantStatus status;

  Contestant({
    required this.contestantId,
    required this.name,
    required this.photoUrl,
    required this.status,
  });
}
