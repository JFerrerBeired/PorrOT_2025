import '../entities/user.dart';

abstract class UserRepository {
  Future<User> createUser({required String displayName});
  Future<List<User>> getUsers();
  Future<User?> getUserById(String id);
  Future<void> updateUser(User user);
}
