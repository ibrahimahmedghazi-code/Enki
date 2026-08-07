// change the bloc to use flutter bloc package 
import 'package:enki/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:enki/core/usecase/usecase.dart';
import 'package:enki/features/auth/domain/usecases/current_user.dart';
import 'package:enki/features/auth/domain/usecases/user_login.dart';
import 'package:enki/features/auth/domain/usecases/user_sign_up.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import materia to make @immutable work because it depend on bloc lib
import 'package:flutter/material.dart';
import 'package:enki/core/common/entites/user.dart';
part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  // create private userSignUp and required UserSignUp
  final UserSignUp _userSignUp;
  final UserLogin _userLogin;
  final CurrentUser _currentUser;
  final AppUserCubit _appUserCubit;

  AuthBloc({
    required UserSignUp userSignUp,
    required UserLogin userLogin,
    required CurrentUser currentUser,
    required AppUserCubit appUserCubit,
  }) : _userSignUp = userSignUp,
  _userLogin = userLogin,
  _currentUser = currentUser,
  _appUserCubit = appUserCubit,
   super(AuthInitial())  {
   on<AuthSignUp>(_onAuthSignUp);
   on<AuthLogin>(_onAuthLogin);
   on<AuthIsUserLoggedIn>(_onAuthIsUserLoggIn);

  }
 void _onAuthIsUserLoggIn(AuthIsUserLoggedIn event, Emitter<AuthState> emit) async{
  _currentUser(NoParams());
  final res = await _currentUser(NoParams());
  res.fold((l)=> emit(AuthFailure(l.message)) , (r) => _emitAuthSuccess(r,emit)) ;
 }

  void _onAuthSignUp(AuthSignUp event,Emitter<AuthState> emit)async {
    emit(AuthLoading());
    // _userSignUp use the direct call of function call 
    final resp = await _userSignUp(UserSignUpParams(name: event.name, email: event.email, password: event.password));
   resp.fold(
    // using var like l and r for left and right to send event about what will happen if respone failed or success
    (failure)=> emit(AuthFailure(failure.message)) ,
    // r is by default is a String
    (user) => _emitAuthSuccess(user,emit),
   );
   }
 void _onAuthLogin(AuthLogin event,Emitter<AuthState> emit)async{
   emit(AuthLoading());
   final res = await _userLogin(UserLoginParams( email: event.email, password: event. password));
   res.fold((l) => emit(AuthFailure(l.message)),(r) => _emitAuthSuccess(r,emit));
 }

 void _emitAuthSuccess(User user, Emitter<AuthState> emit){
  emit(AuthSuccess(user));
  _appUserCubit.updateUser(user);
  emit(AuthSuccess(user));
 }

}
