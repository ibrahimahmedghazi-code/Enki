import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/course.dart';
import '../repository/enki_repository.dart';
 
class GetBeginnerCourses implements UseCase<List<Course>, NoParams> {
  final EnkiRepository repository;
  const GetBeginnerCourses(this.repository);
 
  @override
  Future<Either<Failure, List<Course>>> call(NoParams params) =>
      repository.getBeginnerCourses();
}
