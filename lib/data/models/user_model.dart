import '../../domain/entities/user.dart';

class UserModel extends User {
  final String? id;

  UserModel({this.id, required super.displayName, required super.totalScore});

  factory UserModel.fromFirestore(
    Map<String, dynamic> data,
    String documentId,
  ) {
    return UserModel(
      id: documentId,
      displayName: data['displayName'],
      totalScore: data['totalScore'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {'displayName': displayName, 'totalScore': totalScore};
  }
}
