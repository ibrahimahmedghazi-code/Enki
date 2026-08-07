import 'package:enki/core/secrets/app_secrets.dart';
import '../../domain/entities/user_info_entity.dart';
 
class UserModel extends UserInfoEntity {
  const UserModel({
    required super.userid,
    required super.fullName,
    super.workAt,
    super.age,
    super.description,
    super.speciality,
    required super.profilePicturePath,
  });
 
  factory UserModel.fromJson(Map<String, dynamic> json) {
    final rawPic = json['profilepicturepath'] as String?;
    String profilePic = 'assets/images/app_icon.png';
 
    if (rawPic != null && rawPic.isNotEmpty) {
      if (rawPic.startsWith('http') || rawPic.startsWith('assets')) {
        profilePic = rawPic;
      } else {
        // Just filename — build URL dynamically
        profilePic = '${AppSecrets.apiBaseUrl}/api/v1/stream/image/$rawPic';
      }
    }
 
    return UserModel(
      userid: json['userid'] as String,
      fullName: json['fullname'] as String,
      workAt: json['workat'] as String?,
      age: json['age'] as int?,
      description: json['userdescription'] as String?,
      speciality: json['speciality'] as String?,
      profilePicturePath: profilePic,
    );
  }
}
