import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../entities/course.dart';
import '../entities/user_info_entity.dart';
import '../usecases/update_user.dart'; 

abstract interface class EnkiRepository {
  Future<Either<Failure, List<Course>>> getTopCourses();
  Future<Either<Failure, List<Course>>> getBeginnerCourses();
  Future<Either<Failure, List<Course>>> searchCourses({
    required String query,
    String? category,
  });
  Future<Either<Failure, List<UserInfoEntity>>> searchUsers({
    required String query,
  });
  Future<Either<Failure, UserInfoEntity>> getOrCreateUser({
    required String userid,
  });
  Future<Either<Failure, List<Course>>> getUserWatchedCourses({
    required String userid,
  });

  // ── progress ──────────────────────────────────────────────────
  Future<Either<Failure, List<String>>> getCourseProgress({
    required String userid,
    required String courseid,
  });
  Future<Either<Failure, void>> markLectureFinished({
    required String userid,
    required String courseid,
    required String moduleid,
    required String lectureid,
    required bool isFinished,
  });

  // ── user ──────────────────────────────────────────────────────
  Future<Either<Failure, UserInfoEntity>> updateUser({
    required UpdateUserParams params,
  });
  Future<Either<Failure, void>> enrollUser({
    required String userid,
    required String courseid,
  });
}
