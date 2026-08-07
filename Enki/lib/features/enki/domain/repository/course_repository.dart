import 'package:fpdart/fpdart.dart';
import 'package:enki/core/error/failure.dart';
import 'package:enki/features/enki/domain/entities/course.dart';

abstract interface class CourseRepositor {
  Future<Either<Failure, List<Course>>> searchForTopTenCourses();
  Future<Either<Failure, List<Course>>> searchForTopBeginnersCourses();
  Future<Either<Failure, List<Course>>> searchForCourses({
    required String query,
    String? category,
  });
}
