import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user_info_entity.dart';
import '../repository/enki_repository.dart';
 
class UpdateUser implements UseCase<UserInfoEntity, UpdateUserParams> {
  final EnkiRepository repository;
  const UpdateUser(this.repository);
 
  @override
  Future<Either<Failure, UserInfoEntity>> call(UpdateUserParams params) =>
      repository.updateUser(params: params);
}
 
class UpdateUserParams extends Equatable {
  final String userid;
  final String? fullName;
  final String? workAt;
  final int? age;
  final String? description;
  final String? speciality;
  final String? profilePicturePath;
 
  const UpdateUserParams({
    required this.userid,
    this.fullName,
    this.workAt,
    this.age,
    this.description,
    this.speciality,
    this.profilePicturePath,
  });
 
  @override
  List<Object?> get props =>
      [userid, fullName, workAt, age, description, speciality,profilePicturePath];
}
