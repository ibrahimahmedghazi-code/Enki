part of 'course_material_bloc.dart';

sealed class CourseMaterialState {}

final class CourseMaterialInitial extends CourseMaterialState {}

final class CourseMaterialLoading extends CourseMaterialState {}

final class CourseMaterialFailure extends CourseMaterialState {
  final String message;
  CourseMaterialFailure({required this.message});
}

final class CourseMaterialLoaded extends CourseMaterialState {
  final Map<String, bool> finishedMap;
  CourseMaterialLoaded({required this.finishedMap});

  CourseMaterialLoaded copyWith(Map<String, bool> updated) {
    return CourseMaterialLoaded(finishedMap: {...finishedMap, ...updated});
  }
}
