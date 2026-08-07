import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:enki/init_dependencies.dart';
import 'package:enki/features/enki/presentation/bloc/explore_bloc.dart';
import 'package:enki/features/enki/presentation/bloc/user_info_bloc.dart';
import 'package:enki/features/enki/presentation/bloc/search_bloc.dart';
import 'package:enki/features/enki/presentation/pages/tabs/explore_page.dart';
import 'package:enki/features/enki/presentation/pages/tabs/search_page.dart';
import 'package:enki/features/enki/presentation/pages/tabs/learn_page.dart';
import 'package:enki/features/enki/presentation/pages/tabs/network_page.dart';
import 'package:enki/features/enki/presentation/pages/tabs/account_page.dart';
import 'package:enki/features/enki/presentation/widgets/navi_bar.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;
  late final String _userid;

  // Pages that don't need a shared bloc can be declared here
  final List<Widget> _staticPages = const [
    NetworkPage(),
  ];

  @override
  void initState() {
    super.initState();
    _userid = Supabase.instance.client.auth.currentUser!.id;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // ExploreBloc is lifted here so both ExplorePage and
        // LearnPage share the exact same instance and state
        BlocProvider<ExploreBloc>(
          create: (_) => serviceLocator<ExploreBloc>()
            ..add(ExploreLoad(userid: _userid)),
        ),
        BlocProvider<UserInfoBloc>(
          create: (_) => serviceLocator<UserInfoBloc>()
            ..add(UserInfoLoad(userid: _userid)),
        ),
        BlocProvider<SearchBloc>(
          create: (_) => serviceLocator<SearchBloc>(),
        ),
      ],
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: const [
            ExplorePage(),  
            LearnPage(),    
            SearchPage(),   
            NetworkPage(),
            AccountPage(),  
          ],
        ),
        bottomNavigationBar: NaviBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
        ),
      ),
    );
  }
}
