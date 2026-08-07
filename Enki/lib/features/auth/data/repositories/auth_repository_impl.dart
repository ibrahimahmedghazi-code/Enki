import 'package:enki/core/error/exceptions.dart';
import 'package:enki/core/error/failure.dart';
import 'package:enki/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:enki/core/common/entites/user.dart';
import 'package:enki/features/auth/domain/repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

class AuthRepositoryImpl implements AuthRepository {
  //creating interface for RemoteData 
  final AuthRemoteDataSource remoteDataSource;
  const AuthRepositoryImpl(this.remoteDataSource);
  @override
  Future<Either<Failure, User>> currentUser() async {
    try {

final user = await remoteDataSource.getCurrentUserData();
      if(user==null){
return left(Failure('User not loged in!'));
}
return right(user);
    } on ServerException catch (e){
      return left(Failure(e.message));
    }

  }

  @override
  Future<Either<Failure, User>> loginWithEmailPassword({
    required String email,
     required String password,
      }) async {
    // Sending requst for SignUp and if you get response it mean the opration is successful 
    return _getUser(() async => await remoteDataSource.loginWithEmailPassword(
    email: email, 
    password: password,
    ));

  }

  @override
  Future<Either<Failure, User>> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
    }) async {

    // Sending requst for SignUp and if you get response it mean the opration is successful 
    return _getUser(() async => await remoteDataSource.signUpWithEmailPassword(
    name: name,
    email: email, 
    password: password,
    ));


  }

  // create function to protect User info and make code look simple 
  Future<Either<Failure,User>> _getUser(
Future<User> Function() fn,
  ) async {
    try {
    // Sending requst for SignUp and if you get response it mean the opration is successful 
    final user = await fn();
    // userId should be string 
    return right(user);

  } on sb.AuthException catch (e){
 
   return left(Failure(e.message));
   
  } on ServerException catch (e){
   // use the class ServerException for import error to message type (String)
   // return failure class type 
   return left(Failure(e.message));
   
  }
  }
  


}
