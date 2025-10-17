import '../../domain/entities/contestant.dart';

class ContestantModel extends Contestant {
  ContestantModel({
    super.contestantId,
    required super.name,
    super.photoUrl, // Now optional
    required super.status,
  });

  factory ContestantModel.fromFirestore(
    Map<String, dynamic> data,
    String documentId,
  ) {
    return ContestantModel(
      contestantId: documentId,
      name: data['name'],
      photoUrl: data['photoUrl'], // Will be null if not present
      status: ContestantStatus.values.firstWhere(
        (e) => e.toString() == 'ContestantStatus.${data['status']}',
      ),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      if (photoUrl != null) 'photoUrl': photoUrl, // Only include photoUrl if it's not null
      'status': status.toString().split('.').last,
    };
  }
}
