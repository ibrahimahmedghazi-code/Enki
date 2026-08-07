import 'package:fpdart/fpdart.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/course.dart';
import '../../domain/entities/user_info_entity.dart';
import '../../domain/repository/enki_repository.dart';
import '../datasources/enki_remote_data_source.dart';
import 'package:enki/features/enki/domain/usecases/update_user.dart';

class EnkiRepositoryImpl implements EnkiRepository {
  final EnkiRemoteDataSource remoteDataSource;

  const EnkiRepositoryImpl({required this.remoteDataSource});

  Future<Either<Failure, T>> _safe<T>(Future<T> Function() fn) async {
    try {
      return right(await fn());
    } on ServerException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserInfoEntity>> updateUser({
    required UpdateUserParams params,
  }) => _safe(() => remoteDataSource.updateUser(params: params));

  @override
  Future<Either<Failure, void>> enrollUser({
    required String userid,
    required String courseid,
  }) => _safe(
    () => remoteDataSource.enrollUser(userid: userid, courseid: courseid),
  );

  @override
  Future<Either<Failure, List<Course>>> getTopCourses() =>
      _safe(remoteDataSource.getTopCourses);

  @override
  Future<Either<Failure, List<Course>>> getBeginnerCourses() =>
      _safe(remoteDataSource.getBeginnerCourses);

  @override
  Future<Either<Failure, List<Course>>> searchCourses({
    required String query,
    String? category,
  }) => _safe(
    () => remoteDataSource.searchCourses(query: query, category: category),
  );

  @override
  Future<Either<Failure, List<UserInfoEntity>>> searchUsers({
    required String query,
  }) => _safe(() => remoteDataSource.searchUsers(query: query));

  @override
  Future<Either<Failure, UserInfoEntity>> getOrCreateUser({
    required String userid,
  }) => _safe(() => remoteDataSource.getOrCreateUser(userid: userid));

  @override
  Future<Either<Failure, List<Course>>> getUserWatchedCourses({
    required String userid,
  }) => _safe(() => remoteDataSource.getUserWatchedCourses(userid: userid));

  // ── progress ───────────────────────────────────────────────────
  @override
  Future<Either<Failure, List<String>>> getCourseProgress({
    required String userid,
    required String courseid,
  }) => _safe(
    () =>
        remoteDataSource.getCourseProgress(userid: userid, courseid: courseid),
  );

  @override
  Future<Either<Failure, void>> markLectureFinished({
    required String userid,
    required String courseid,
    required String moduleid,
    required String lectureid,
    required bool isFinished,
  }) => _safe(
    () => remoteDataSource.markLectureFinished(
      userid: userid,
      courseid: courseid,
      moduleid: moduleid,
      lectureid: lectureid,
      isFinished: isFinished,
    ),
  );
}
