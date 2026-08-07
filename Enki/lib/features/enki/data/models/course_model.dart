import 'package:enki/core/secrets/app_secrets.dart';
import '../../domain/entities/course.dart';
import 'module_model.dart';
 
class CourseModel extends Course {
  const CourseModel({
    required super.courseid,
    required super.title,
    super.author,
    super.description,
    super.category,
    super.level,
    super.imagePath,
    required super.rating,
    required super.modules,
    super.enrolledAt,
    super.lastWatchedAt,
  });
 
  factory CourseModel.fromJson(Map<String, dynamic> json) {
    final rawImage = json['imagepath'] as String?;
    String? fullImagePath;
 
    if (rawImage != null && rawImage.isNotEmpty) {
      if (rawImage.startsWith('http') || rawImage.startsWith('assets')) {
        // Full URL or asset path — use as is
        fullImagePath = rawImage;
      } else {
        // Just a filename — build URL dynamically
        fullImagePath = '${AppSecrets.apiBaseUrl}/api/v1/stream/image/$rawImage';
      }
    }
 
    return CourseModel(
      courseid: json['courseid'] as String,
      title: json['title'] as String,
      author: json['author'] as String?,
      description: json['description'] as String?,
      category: json['category'] as String?,
      level: json['stage'] as String?,
      imagePath: fullImagePath,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      modules: (json['modules'] as List<dynamic>? ?? [])
          .map((m) => ModuleModel.fromJson(m as Map<String, dynamic>))
          .toList(),
      enrolledAt: json['enrolledat'] != null
          ? DateTime.tryParse(json['enrolledat'] as String)
          : null,
      lastWatchedAt: json['lastwatchedat'] != null
          ? DateTime.tryParse(json['lastwatchedat'] as String)
          : null,
    );
  }
}
