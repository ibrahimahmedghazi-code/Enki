import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/course.dart';
import '../repository/enki_repository.dart';
 
class GetUserWatchedCourses
    implements UseCase<List<Course>, GetUserWatchedCoursesParams> {
  final EnkiRepository repository;
  const GetUserWatchedCourses(this.repository);
 
  @override
  Future<Either<Failure, List<Course>>> call(
    GetUserWatchedCoursesParams params,
  ) =>
      repository.getUserWatchedCourses(userid: params.userid);
}
 
class GetUserWatchedCoursesParams extends Equatable {
  final String userid;
  const GetUserWatchedCoursesParams({required this.userid});
 
  @override
  List<Object?> get props => [userid];
}
