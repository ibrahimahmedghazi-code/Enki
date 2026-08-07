import 'package:equatable/equatable.dart';
import 'lecture.dart';
 
class Module extends Equatable {
  final String moduleid;
  final int? numberOfModule;
  final List<Lecture> lectures;
 
  const Module({
    required this.moduleid,
    this.numberOfModule,
    required this.lectures,
  });
 
  @override
  List<Object?> get props => [moduleid];
}
