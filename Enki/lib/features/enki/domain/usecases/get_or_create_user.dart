import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user_info_entity.dart';
import '../repository/enki_repository.dart';
 
class GetOrCreateUser
    implements UseCase<UserInfoEntity, GetOrCreateUserParams> {
  final EnkiRepository repository;
  const GetOrCreateUser(this.repository);
 
  @override
  Future<Either<Failure, UserInfoEntity>> call(
    GetOrCreateUserParams params,
  ) =>
      repository.getOrCreateUser(userid: params.userid);
}
 
class GetOrCreateUserParams extends Equatable {
  final String userid;
  const GetOrCreateUserParams({required this.userid});
 
  @override
  List<Object?> get props => [userid];
}
