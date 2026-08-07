import 'package:enki/core/common/entites/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'app_user_state.dart';

class AppUserCubit extends Cubit<AppUserState> {
  AppUserCubit() : super(AppUserInitial());
  void updateUser(User? user){
    if(user == null){
      // user if user are logged out so sending him back to initial state
      emit(AppUserInitial());
    }else{
      emit(AppUserLoggedIn(user));
    }
  }
  String? get currentUserId {
    final currentState = state;
    if (currentState is AppUserLoggedIn) {
      return currentState.user.id;
    }
    return null;
  }
}
