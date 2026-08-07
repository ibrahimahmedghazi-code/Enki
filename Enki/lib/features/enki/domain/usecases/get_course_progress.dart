import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../../core/error/failure.dart';
import '../../../../../core/usecase/usecase.dart';
import '../../domain/repository/enki_repository.dart';

class GetCourseProgress
    implements UseCase<List<String>, GetCourseProgressParams> {
  final EnkiRepository repository;
  const GetCourseProgress(this.repository);

  @override
  Future<Either<Failure, List<String>>> call(
    GetCourseProgressParams params,
  ) =>
      repository.getCourseProgress(
        userid: params.userid,
        courseid: params.courseid,
      );
}

class GetCourseProgressParams extends Equatable {
  final String userid;
  final String courseid;

  const GetCourseProgressParams({
    required this.userid,
    required this.courseid,
  });

  @override
  List<Object?> get props => [userid, courseid];
}
