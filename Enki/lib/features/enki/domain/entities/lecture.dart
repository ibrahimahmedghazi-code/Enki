import 'package:equatable/equatable.dart';

class Lecture extends Equatable {
  final String lectureid;
  final String? title;
  final int? lectureOrder;
  final int? durationMinutes;
  final bool isItVideo;
  final String? lectureUrl;
  final bool isFinished;

  const Lecture({
    required this.lectureid,
    this.title,
    this.lectureOrder,
    this.durationMinutes,
    required this.isItVideo,
    this.lectureUrl,
    this.isFinished = false,
  });

  Lecture copyWith({bool? isFinished}) {
    return Lecture(
      lectureid: lectureid,
      title: title,
      lectureOrder: lectureOrder,
      durationMinutes: durationMinutes,
      isItVideo: isItVideo,
      lectureUrl: lectureUrl,
      isFinished: isFinished ?? this.isFinished,
    );
  }

  @override
  List<Object?> get props => [lectureid, isFinished];
}
