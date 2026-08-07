import 'package:enki/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:enki/core/themes/app_colors.dart';
import 'package:enki/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:enki/features/auth/presentation/pages/login_page.dart';
import 'package:enki/features/enki/presentation/pages/home_shell.dart';
import 'package:enki/init_dependencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yaru/yaru.dart';
import 'package:media_kit/media_kit.dart';


void main() async {
  // Initialized Widget before the backend
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  await initDependencies();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => serviceLocator<AppUserCubit>()),
        BlocProvider(create: (_) => serviceLocator<AuthBloc>()),
      ],

      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(AuthIsUserLoggedIn());
  }

  @override
  Widget build(BuildContext context) {
    return YaruTheme(
      // Set the variant to yellow here
      data: const YaruThemeData(variant: YaruVariant.adwaitaYellow),

      builder: (context, yaru, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Enki',

          theme: yaru.darkTheme!.copyWith(
            splashFactory: NoSplash.splashFactory,
            highlightColor: AppColors.enkiTransparent,
            appBarTheme: const AppBarTheme( elevation: 0.0, shadowColor: AppColors.enkiTransparent,)
          ),
// routing function if user is logged in or not 
          home: BlocSelector<AppUserCubit,AppUserState, bool>(
            selector: (state) {
              return state is AppUserLoggedIn;
            },
            builder: (context, isLoggedIn) {
              if(isLoggedIn){
                return const HomeShell();
              }
              return const LoginPage();
            },
          ),
        );
      },
    );
  }
}
