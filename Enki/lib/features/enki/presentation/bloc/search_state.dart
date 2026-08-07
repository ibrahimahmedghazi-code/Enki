part of 'search_bloc.dart';
 
@immutable
sealed class SearchState {}
 
final class SearchInitial extends SearchState {}
 
final class SearchLoading extends SearchState {}
 
final class SearchFailure extends SearchState {
  final String message;
  SearchFailure({required this.message});
}
 
final class SearchCoursesLoaded extends SearchState {
  final List<Course> courses;
  SearchCoursesLoaded({required this.courses});
}
 
final class SearchUsersLoaded extends SearchState {
  final List<UserInfoEntity> users;
  SearchUsersLoaded({required this.users});
}
