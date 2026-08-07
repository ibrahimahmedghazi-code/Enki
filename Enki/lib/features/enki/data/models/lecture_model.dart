import 'package:enki/core/secrets/app_secrets.dart';
import '../../domain/entities/lecture.dart';

class LectureModel extends Lecture {
  const LectureModel({
    required super.lectureid,
    super.title,
    super.lectureOrder,
    super.durationMinutes,
    required super.isItVideo,
    super.lectureUrl,
    super.isFinished = false,
  });

factory LectureModel.fromJson(Map<String, dynamic> json) {
  final isItVideo = json['isitvideo'] as bool? ?? true;
  final rawUrl = json['lectureurl'] as String?;

  String? fullUrl;
  if (rawUrl != null && rawUrl.isNotEmpty) {
    // Extract just the filename regardless of what's stored
    final filename = rawUrl.contains('/')
        ? rawUrl.split('/').last
        : rawUrl;

    if (isItVideo) {
      // Nginx serves videos — fast, no Python overhead
      fullUrl = '${AppSecrets.mediaBaseUrl}/media/videos/$filename';
    } else {
      // FastAPI serves markdown articles
      fullUrl = '${AppSecrets.apiBaseUrl}/api/v1/stream/article/$filename';
    }
  }

  return LectureModel(
    lectureid: json['lectureid'] as String,
    title: json['title'] as String?,
    lectureOrder: json['lectureorder'] as int?,
    durationMinutes: json['durationminutes'] as int?,
    isItVideo: isItVideo,
    lectureUrl: fullUrl,
    isFinished: json['isfinished'] as bool? ?? false,
  );
  }
}
