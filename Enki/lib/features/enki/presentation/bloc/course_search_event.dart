part of 'course_search_bloc.dart';

@immutable
sealed class CourseSearchEvent {}
final class CourseSearchGetTopTen extends CourseSearchEvent{}
final class CourseSearchGetBeginner extends CourseSearchEvent{}
