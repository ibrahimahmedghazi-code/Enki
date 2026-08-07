import 'package:enki/core/common/entites/user.dart';

class UserModel extends User {
  UserModel({required super.email, required super.name, required super.id});

factory UserModel.fromJson(Map <String, dynamic> map ){
  return UserModel(email: map['email'] ?? '', name: map['name'] ?? '', id: map['id'] ?? '');
}

 UserModel copyWith({
    String? email,
    String? name,
    String? id,
  }) {
    return UserModel(
      email: email ?? this.email,
      name: name ?? this.name,
      id: id ?? this.id,
    );
  }


}