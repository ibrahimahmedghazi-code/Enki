// class to handel data from login/signup page 
import 'package:enki/core/error/exceptions.dart';
import 'package:enki/features/auth/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class AuthRemoteDataSource {
  Session? get currentUserSession;
  Future<UserModel> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  });
Future<UserModel> loginWithEmailPassword({
    required String email,
    required String password,
  });
  Future<UserModel?> getCurrentUserData();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;
  AuthRemoteDataSourceImpl(this.supabaseClient);
  @override
  Session? get currentUserSession => supabaseClient.auth.currentSession;
  @override
  Future<UserModel> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  })async{
    try {
    final response = await supabaseClient.auth.signUp(
      password: password,
     email: email,
     data:{'name':name},
     );
     // check if user is not null value 
     if (response.user == null){
      throw  const ServerException("User is not exist");
     }
     return UserModel.fromJson(response.user!.toJson());
    }
    catch(e){
      throw ServerException(e.toString());

    }
  }
@override
Future<UserModel> loginWithEmailPassword({
    required String email,
    required String password,
  })async{
    try {
    final response = await supabaseClient.auth.signInWithPassword(
      password: password,
     email: email,
     );
     // check if user is not null value 
     if (response.user == null){
      throw  const ServerException("User is not exist");
     }
     return UserModel.fromJson(response.user!.toJson());
    }
    catch(e){
      throw ServerException(e.toString());

    }
  }

  @override
    Future<UserModel?> getCurrentUserData()async{
      // function to get the just one user form map table in supabase database and return the current user row 
     try{
      if(currentUserSession!=null){
     final userData = await supabaseClient.from('profiles').select().eq('id', currentUserSession!.user.id);
     return UserModel.fromJson(userData.first).copyWith(
      // to update the email info and make it retrivable
      email:  currentUserSession!.user.email,
     );
     }
     return null;
     } catch(e) {
      throw ServerException(e.toString());
     }
    
  }
}
