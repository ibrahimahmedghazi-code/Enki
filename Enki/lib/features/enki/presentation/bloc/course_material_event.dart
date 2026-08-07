part of 'course_material_bloc.dart';

sealed class CourseMaterialEvent {}

final class CourseMaterialLoad extends CourseMaterialEvent {
  final String userid;
  final String courseid;
  final List<dynamic> modules;
  CourseMaterialLoad({
    required this.userid,
    required this.courseid,
    required this.modules,
  });
}

final class CourseMaterialToggleLecture extends CourseMaterialEvent {
  final String userid;
  final String courseid;
  final String moduleid;
  final String lectureid;
  final bool isFinished;
  CourseMaterialToggleLecture({
    required this.userid,
    required this.courseid,
    required this.moduleid,
    required this.lectureid,
    required this.isFinished,
  });
}
