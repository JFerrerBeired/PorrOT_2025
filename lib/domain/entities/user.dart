class User {
  final String? id; // Add this
  final String displayName;
  final int totalScore;

  User({
    this.id,
    required this.displayName,
    required this.totalScore,
  }); // Update constructor
}
