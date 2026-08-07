import 'package:enki/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:enki/core/secrets/app_secrets.dart';
import 'package:enki/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:enki/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:enki/features/auth/domain/repository/auth_repository.dart';
import 'package:enki/features/auth/domain/usecases/current_user.dart';
import 'package:enki/features/auth/domain/usecases/user_login.dart';
import 'package:enki/features/auth/domain/usecases/user_sign_up.dart';
import 'package:enki/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'features/enki/data/datasources/enki_remote_data_source.dart';
import 'features/enki/data/repositories/enki_repository_impl.dart';
import 'features/enki/domain/repository/enki_repository.dart';
import 'features/enki/domain/usecases/get_top_courses.dart';
import 'features/enki/domain/usecases/get_beginner_courses.dart';
import 'features/enki/domain/usecases/search_courses.dart';
import 'features/enki/domain/usecases/search_users.dart';
import 'features/enki/domain/usecases/get_user_watched_courses.dart';
import 'features/enki/domain/usecases/get_or_create_user.dart';
import 'package:enki/features/enki/presentation/bloc/user_info_bloc.dart';
import 'package:enki/features/enki/presentation/bloc/explore_bloc.dart';
import 'package:enki/features/enki/presentation/bloc/search_bloc.dart';
import 'package:enki/features/enki/domain/usecases/update_user.dart';
import 'package:enki/features/enki/domain/usecases/get_course_progress.dart';
import 'package:enki/features/enki/domain/usecases/mark_lecture_finished.dart';
import 'package:enki/features/enki/presentation/bloc/course_material_bloc.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  // 1. Supabase must be first — auth depends on its client
  final supabase = await Supabase.initialize(
    url: AppSecrets.supabaseUrl,
    anonKey: AppSecrets.supabaseAnnonKey,
  );
  serviceLocator.registerLazySingleton(() => supabase.client);

  // 2. Core
  serviceLocator.registerLazySingleton(() => AppUserCubit());

  // 3. Features — order matters, auth uses supabase client above
  _initAuth();
  _initEnki();
}

void _initAuth() {
  serviceLocator
    ..registerFactory<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(serviceLocator()),
    )
    ..registerFactory<AuthRepository>(
      () => AuthRepositoryImpl(serviceLocator()),
    )
    ..registerFactory(() => UserSignUp(serviceLocator()))
    ..registerFactory(() => UserLogin(serviceLocator()))
    ..registerFactory(() => CurrentUser(serviceLocator()))
    ..registerLazySingleton(
      () => AuthBloc(
        userSignUp: serviceLocator(),
        userLogin: serviceLocator(),
        currentUser: serviceLocator(),
        appUserCubit: serviceLocator(),
      ),
    );
}

void _initEnki() {
  serviceLocator.registerLazySingleton<http.Client>(() => http.Client());

  serviceLocator.registerLazySingleton<EnkiRemoteDataSource>(
    () => EnkiRemoteDataSourceImpl(
      client: serviceLocator<http.Client>(),
      baseUrl: AppSecrets.apiBaseUrl,
    ),
  );

  serviceLocator.registerLazySingleton<EnkiRepository>(
    () => EnkiRepositoryImpl(
      remoteDataSource: serviceLocator<EnkiRemoteDataSource>(),
    ),
  );

  serviceLocator.registerLazySingleton(
    () => GetTopCourses(serviceLocator<EnkiRepository>()),
  );
  serviceLocator.registerLazySingleton(
    () => GetBeginnerCourses(serviceLocator<EnkiRepository>()),
  );
  serviceLocator.registerLazySingleton(
    () => SearchCourses(serviceLocator<EnkiRepository>()),
  );
  serviceLocator.registerLazySingleton(
    () => SearchUsers(serviceLocator<EnkiRepository>()),
  );
  serviceLocator.registerLazySingleton(
    () => GetUserWatchedCourses(serviceLocator<EnkiRepository>()),
  );
  serviceLocator.registerLazySingleton(
    () => GetOrCreateUser(serviceLocator<EnkiRepository>()),
  );
  serviceLocator.registerFactory(
    () => UserInfoBloc(
      getOrCreateUser: serviceLocator(),
      updateUser: serviceLocator(),
    ),
  );
  serviceLocator.registerFactory(
    () => ExploreBloc(
      getTopCourses: serviceLocator(),
      getBeginnerCourses: serviceLocator(),
      getUserWatchedCourses: serviceLocator(),
    ),
  );
  serviceLocator.registerFactory(
    () => SearchBloc(
      searchCourses: serviceLocator(),
      searchUsers: serviceLocator(),
    ),
  );
  serviceLocator.registerLazySingleton(
    () => UpdateUser(serviceLocator<EnkiRepository>()),
  );
  serviceLocator.registerLazySingleton(
  () => GetCourseProgress(serviceLocator<EnkiRepository>()),
);
serviceLocator.registerLazySingleton(
  () => MarkLectureFinished(serviceLocator<EnkiRepository>()),
);
serviceLocator.registerFactory(
  () => CourseMaterialBloc(
    getCourseProgress: serviceLocator(),
    markLectureFinished: serviceLocator(),
  ),
);
}
