import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../models/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  final FirebaseFirestore _firestore;

  UserRepositoryImpl(this._firestore);

  @override
  Future<void> createUser(User user) async {
    final userModel = UserModel(
      displayName: user.displayName,
      totalScore: user.totalScore,
    );
    await _firestore.collection('users').add(userModel.toFirestore());
  }

  @override
  Future<List<User>> getAllUsers() async {
    final snapshot = await _firestore.collection('users').get();
    return snapshot.docs
        .map((doc) => UserModel.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<User?> getUserById(String id) async {
    final doc = await _firestore.collection('users').doc(id).get();
    if (doc.exists) {
      return UserModel.fromFirestore(doc.data()!, doc.id);
    }
    return null;
  }

  @override
  Future<void> updateUser(User user) async {
    final userModel = user as UserModel;
    await _firestore
        .collection('users')
        .doc(userModel.id)
        .update(userModel.toFirestore());
  }
}
