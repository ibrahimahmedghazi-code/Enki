import 'package:enki/core/error/failure.dart';
import 'package:enki/core/usecase/usecase.dart';
import 'package:enki/core/common/entites/user.dart';
import 'package:enki/features/auth/domain/repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class UserSignUp implements UseCase<User, UserSignUpParams> {
  // Solving the dependency by using dependency injection so should not be dependent on domain layer 
  final AuthRepository authRepository;
  const UserSignUp(this.authRepository);
  @override 
  Future<Either<Failure, User>> call(UserSignUpParams params) async {
  // it all ready Failure or String so just return the response
  return authRepository.signUpWithEmailPassword(
    name: params.name
  , email: params.email, 
  password: params.password,
  );
  }

}

class UserSignUpParams {
  final String name;
  final String email;
  final String password;
  UserSignUpParams({
    required this.name,
    required this.email,
    required this.password,
  });
}
