
import '../entities/user.dart';
import '../repositories/user_repository.dart';

class CreateUserUseCase {
  final UserRepository userRepository;

  CreateUserUseCase(this.userRepository);

  Future<User> call({required String displayName}) {
    return userRepository.createUser(displayName: displayName);
  }
}
