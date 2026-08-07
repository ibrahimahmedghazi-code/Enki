import 'package:equatable/equatable.dart';
import 'module.dart';
 
class Course extends Equatable {
  final String courseid;
  final String title;
  final String? author;
  final String? description;
  final String? category;
  final String? level;      
  final String? imagePath;  
  final double rating;
  final List<Module> modules;
  final DateTime? enrolledAt;
  final DateTime? lastWatchedAt;
 
  const Course({
    required this.courseid,
    required this.title,
    this.author,
    this.description,
    this.category,
    this.level,
    this.imagePath,
    required this.rating,
    required this.modules,
    this.enrolledAt,
    this.lastWatchedAt,
  });
 
  @override
  List<Object?> get props => [courseid];
}
