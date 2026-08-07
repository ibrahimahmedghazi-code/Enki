import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user_info_entity.dart';
import '../repository/enki_repository.dart';
 
class SearchUsers implements UseCase<List<UserInfoEntity>, SearchUsersParams> {
  final EnkiRepository repository;
  const SearchUsers(this.repository);
 
  @override
  Future<Either<Failure, List<UserInfoEntity>>> call(
    SearchUsersParams params,
  ) =>
      repository.searchUsers(query: params.query);
}
 
class SearchUsersParams extends Equatable {
  final String query;
  const SearchUsersParams({required this.query});
 
  @override
  List<Object?> get props => [query];
}
 
