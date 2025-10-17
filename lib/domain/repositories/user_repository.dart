import '../entities/user.dart';

abstract class UserRepository {
  Future<void> createUser(User user);
  Future<List<User>> getAllUsers();
  Future<User?> getUserById(String id);
  Future<void> updateUser(User user);
}
