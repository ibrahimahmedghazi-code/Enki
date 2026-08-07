import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/course.dart';
import '../repository/enki_repository.dart';
 
class SearchCourses implements UseCase<List<Course>, SearchCoursesParams> {
  final EnkiRepository repository;
  const SearchCourses(this.repository);
 
  @override
  Future<Either<Failure, List<Course>>> call(SearchCoursesParams params) =>
      repository.searchCourses(
        query: params.query,
        category: params.category,
      );
}
 
class SearchCoursesParams extends Equatable {
  final String query;
  final String? category;
 
  const SearchCoursesParams({required this.query, this.category});
 
  @override
  List<Object?> get props => [query, category];
}
