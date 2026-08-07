part of 'course_search_bloc.dart';

@immutable
sealed class  CourseSearchState {}
final class CourseSearchInitial extends CourseSearchState{}
final class CourseSearchLoading extends CourseSearchState{}
final class CourseSearchFinish extends CourseSearchState{}
final class CourseSearchFailure extends CourseSearchState{}
