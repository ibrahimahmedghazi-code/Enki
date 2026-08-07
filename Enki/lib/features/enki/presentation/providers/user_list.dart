import 'package:enki/features/enki/domain/entities/user_info_entity.dart';
import 'package:enki/features/enki/data/models/user_model.dart';

class UserList {
  // Use 'static final' instead of 'static const' if your Model 
  // has any non-const logic or if the compiler complains.
  static const List<UserInfoEntity> followedUsers = [
    UserModel(
      userid: '1', // Changed 'id' to 'userid' to match your Model
      fullName: 'Felix',
      description: 'pentester who love to discovering new vurinabllity',
      age: 23,
      profilePicturePath: 'assets/images/app_icon.png',
      speciality: 'IT',
      workAt: 'Google',
    ),
    UserModel(
      userid: '2', // Changed 'id' to 'userid' to match your Model
      fullName: 'Alex',
      description: 'experance system admin',
      age: 25,
      profilePicturePath: 'assets/images/app_icon.png',
      speciality: 'IT',
      workAt: 'Microsoft',
    ),
  ];
}
