part of 'user_info_bloc.dart';
 
sealed class UserInfoEvent {}
 
final class UserInfoLoad extends UserInfoEvent {
  final String userid;
  UserInfoLoad({required this.userid});
}
 
final class UserInfoUpdate extends UserInfoEvent {
  final UpdateUserParams params;
  UserInfoUpdate({required this.params});
}
