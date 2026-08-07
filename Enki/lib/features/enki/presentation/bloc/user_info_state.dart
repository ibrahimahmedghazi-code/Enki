part of 'user_info_bloc.dart';
 
sealed class UserInfoState {}
 
final class UserInfoInitial extends UserInfoState {}
 
final class UserInfoLoading extends UserInfoState {}
 
final class UserInfoUpdating extends UserInfoState {}
 
final class UserInfoLoaded extends UserInfoState {
  final UserInfoEntity user;
  UserInfoLoaded({required this.user});
}
 
final class UserInfoFailure extends UserInfoState {
  final String message;
  UserInfoFailure({required this.message});
}
