import '../../domain/entities/module.dart';
import 'lecture_model.dart';
 
class ModuleModel extends Module {
  const ModuleModel({
    required super.moduleid,
    super.numberOfModule,
    required super.lectures,
  });
 
  factory ModuleModel.fromJson(Map<String, dynamic> json) {
    return ModuleModel(
      moduleid: json['moduleid'] as String,
      numberOfModule: json['numberofmodule'] as int?, // DB snake_case → camelCase
      lectures: (json['lectures'] as List<dynamic>? ?? [])
          .map((l) => LectureModel.fromJson(l as Map<String, dynamic>))
          .toList(),
    );
  }
}
