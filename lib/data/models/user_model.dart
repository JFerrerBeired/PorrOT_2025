import '../../domain/entities/user.dart';

class UserModel extends User {
  // No 'id' field here, it's inherited from User

  UserModel({
    super.id, // Pass id to super constructor
    required super.displayName,
    required super.totalScore,
  });

  factory UserModel.fromFirestore(
    Map<String, dynamic> data,
    String documentId,
  ) {
    return UserModel(
      id: documentId, // Pass documentId as id
      displayName: data['displayName'],
      totalScore: data['totalScore'],
    );
  }

  Map<String, dynamic> toFirestore() {
    // id is not stored in Firestore for new documents, it's the document ID
    return {'displayName': displayName, 'totalScore': totalScore};
  }
}
