import 'package:equatable/equatable.dart';
 
class UserInfoEntity extends Equatable {
  final String userid;
  final String fullName;
  final String? workAt;
  final int? age;
  final String? description;
  final String? speciality;
  final String profilePicturePath;
 
  const UserInfoEntity({
    required this.userid,
    required this.fullName,
    this.workAt,
    this.age,
    this.description,
    this.speciality,
    required this.profilePicturePath,
  });
 
  UserInfoEntity copyWith({
    String? fullName,
    String? workAt,
    int? age,
    String? description,
    String? speciality,
    String? profilePicturePath,
  }) {
    return UserInfoEntity(
      userid: userid,
      fullName: fullName ?? this.fullName,
      workAt: workAt ?? this.workAt,
      age: age ?? this.age,
      description: description ?? this.description,
      speciality: speciality ?? this.speciality,
      profilePicturePath: profilePicturePath ?? this.profilePicturePath,
    );
  }
 
  @override
  List<Object?> get props => [userid];
}
