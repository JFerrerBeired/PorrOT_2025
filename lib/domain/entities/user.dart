class User {
  final String? id; // Add this
  final String displayName;
  final int totalScore;

  User({
    this.id,
    required this.displayName,
    required this.totalScore,
  }); // Update constructor

  User copyWith({
    String? id,
    String? displayName,
    int? totalScore,
  }) {
    return User(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      totalScore: totalScore ?? this.totalScore,
    );
  }
}
