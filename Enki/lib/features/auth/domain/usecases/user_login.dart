// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:enki/core/usecase/usecase.dart';
import 'package:enki/core/common/entites/user.dart';
import 'package:enki/core/error/failure.dart';
import 'package:enki/features/auth/domain/repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class UserLogin implements UseCase<User, UserLoginParams > {
  final AuthRepository authRepository;
  const UserLogin(this.authRepository);
@override
Future<Either<Failure,User>> call(UserLoginParams params) async {
return await authRepository.loginWithEmailPassword(email: params.email, password: params.password);
}
  }



class UserLoginParams {

  final String email;
  final String password;
  UserLoginParams({
    required this.email,
    required this.password,
  });
}
