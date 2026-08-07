import 'package:enki/core/error/failure.dart';
import 'package:enki/core/usecase/usecase.dart';
import 'package:enki/core/common/entites/user.dart';
import 'package:enki/features/auth/domain/repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class CurrentUser implements UseCase<User, NoParams>{

  final AuthRepository authRepository;
  CurrentUser(this.authRepository);
  @override
  Future<Either<Failure, User>> call(NoParams params) async {
  return await authRepository.currentUser();
  }

}
