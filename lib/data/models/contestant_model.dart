import '../../domain/entities/contestant.dart';

class ContestantModel extends Contestant {
  ContestantModel({
    required super.contestantId,
    required super.name,
    required super.photoUrl,
    required super.status,
  });

  factory ContestantModel.fromFirestore(
    Map<String, dynamic> data,
    String documentId,
  ) {
    return ContestantModel(
      contestantId: documentId,
      name: data['name'],
      photoUrl: data['photoUrl'],
      status: ContestantStatus.values.firstWhere(
        (e) => e.toString() == 'ContestantStatus.${data['status']}',
      ),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'photoUrl': photoUrl,
      'status': status.toString().split('.').last,
    };
  }
}
