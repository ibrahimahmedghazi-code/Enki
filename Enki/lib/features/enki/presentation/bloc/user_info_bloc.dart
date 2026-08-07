import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:enki/features/enki/domain/entities/user_info_entity.dart';
import 'package:enki/features/enki/domain/usecases/get_or_create_user.dart';
import 'package:enki/features/enki/domain/usecases/update_user.dart';
 
part 'user_info_event.dart';
part 'user_info_state.dart';
 
class UserInfoBloc extends Bloc<UserInfoEvent, UserInfoState> {
  final GetOrCreateUser _getOrCreateUser;
  final UpdateUser _updateUser;
 
  UserInfoBloc({
    required GetOrCreateUser getOrCreateUser,
    required UpdateUser updateUser,
  })  : _getOrCreateUser = getOrCreateUser,
        _updateUser = updateUser,
        super(UserInfoInitial()) {
    on<UserInfoLoad>(_onUserInfoLoad);
    on<UserInfoUpdate>(_onUserInfoUpdate);
  }
 
  Future<void> _onUserInfoLoad(
    UserInfoLoad event,
    Emitter<UserInfoState> emit,
  ) async {
    emit(UserInfoLoading());
    final result = await _getOrCreateUser(
      GetOrCreateUserParams(userid: event.userid),
    );
    result.fold(
      (failure) => emit(UserInfoFailure(message: failure.message)),
      (user) => emit(UserInfoLoaded(user: user)),
    );
  }
 
  Future<void> _onUserInfoUpdate(
    UserInfoUpdate event,
    Emitter<UserInfoState> emit,
  ) async {
    final current = state;
    emit(UserInfoUpdating());
    final result = await _updateUser(event.params);
    result.fold(
      (failure) => emit(current), // restore previous state on failure
      (user) => emit(UserInfoLoaded(user: user)),
    );
  }
}
