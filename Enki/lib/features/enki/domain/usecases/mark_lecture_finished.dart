import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../repository/enki_repository.dart';

class MarkLectureFinished
    implements UseCase<void, MarkLectureFinishedParams> {
  final EnkiRepository repository;
  const MarkLectureFinished(this.repository);

  @override
  Future<Either<Failure, void>> call(MarkLectureFinishedParams params) =>
      repository.markLectureFinished(
        userid: params.userid,
        courseid: params.courseid,
        moduleid: params.moduleid,
        lectureid: params.lectureid,
        isFinished: params.isFinished,
      );
}

class MarkLectureFinishedParams extends Equatable {
  final String userid;
  final String courseid;
  final String moduleid;
  final String lectureid;
  final bool isFinished;

  const MarkLectureFinishedParams({
    required this.userid,
    required this.courseid,
    required this.moduleid,
    required this.lectureid,
    required this.isFinished,
  });

  @override
  List<Object?> get props =>
      [userid, courseid, moduleid, lectureid, isFinished];
}
