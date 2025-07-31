import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/auth/auth_bloc.dart';
import 'blocs/auth/auth_state.dart';
import 'repositories/auth_repository.dart';
import 'repositories/course_repository.dart';
import 'repositories/leaderboard_repository.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_navigation.dart';
import 'theme/theme_cubit.dart';

class App extends StatelessWidget {
  final AuthRepository authRepository;
  final CourseRepository courseRepository;
  final LeaderboardRepository leaderboardRepository;

  const App({
    super.key,
    required this.authRepository,
    required this.courseRepository,
    required this.leaderboardRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: authRepository),
        RepositoryProvider.value(value: courseRepository),
        RepositoryProvider.value(value: leaderboardRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => AuthBloc(authRepository: authRepository),
          ),
          BlocProvider(
            create: (_) => ThemeCubit(),
          ),
        ],
        child: const AppView(),
      ),
    );
  }
}

class AppView extends StatefulWidget {
  const AppView({super.key});

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  NavigatorState get _navigator => _navigatorKey.currentState!;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Fulminant Learning',
          theme: themeState.themeData,
          navigatorKey: _navigatorKey,
          builder: (context, child) {
            return BlocListener<AuthBloc, AuthState>(
              listener: (context, state) {
                switch (state.status) {
                  case AuthStatus.authenticated:
                    _navigator.pushAndRemoveUntil<void>(
                      MainNavigation.route(),
                      (route) => false,
                    );
                    break;
                  case AuthStatus.unauthenticated:
                    _navigator.pushAndRemoveUntil<void>(
                      LoginScreen.route(),
                      (route) => false,
                    );
                    break;
                  case AuthStatus.unknown:
                    break;
                }
              },
              child: child,
            );
          },
          onGenerateRoute: (_) => SplashPage.route(),
        );
      },
    );
  }
}

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const SplashPage());
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
