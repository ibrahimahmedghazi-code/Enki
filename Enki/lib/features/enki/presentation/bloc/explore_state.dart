part of 'explore_bloc.dart';
 
@immutable
sealed class ExploreState {}
 
final class ExploreInitial extends ExploreState {}
 
final class ExploreLoading extends ExploreState {}
 
final class ExploreFailure extends ExploreState {
  final String message;
  ExploreFailure({required this.message});
}
 
final class ExploreLoaded extends ExploreState {
  final Course? currentCourse;       // last watched — null if user never watched
  final List<Course> topRated;
  final List<Course> beginner;
  final List<Course> watchedCourses;
 
  ExploreLoaded({
    required this.currentCourse,
    required this.topRated,
    required this.beginner,
    required this.watchedCourses,
  });
}
