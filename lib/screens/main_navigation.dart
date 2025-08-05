import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/auth/auth_state.dart';
import '../blocs/course/course_bloc.dart';
import '../blocs/course/course_state.dart';
import '../blocs/leaderboard/leaderboard_bloc.dart';
import '../blocs/leaderboard/leaderboard_event.dart';
import '../repositories/course_repository.dart';
import '../repositories/leaderboard_repository.dart';
import 'home/home_screen.dart';
import 'course/courses_list_screen.dart';
import 'leaderboard/leaderboard_screen.dart';
import 'profile/profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const MainNavigation());
  }

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  CourseBloc? _courseBloc;
  LeaderboardBloc? _leaderboardBloc;

  final List<String> _titles = [
    'Fulminant Learning',
    'Courses',
    'Leaderboard',
    'Profile',
  ];

  final List<Widget> _screens = [
    const HomeContent(),
    const CoursesListScreen(),
    const LeaderboardScreen(showScaffold: false),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => _courseBloc = CourseBloc(
            courseRepository: context.read<CourseRepository>(),
          ),
        ),
        BlocProvider(
          create: (context) => _leaderboardBloc = LeaderboardBloc(
            leaderboardRepository: context.read<LeaderboardRepository>(),
          ),
        ),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<CourseBloc, CourseState>(
            listener: (context, courseState) {
              // Listen for any changes in course state and refresh leaderboard
              final authState = context.read<AuthBloc>().state;
              if (authState.status == AuthStatus.authenticated &&
                  authState.user != null) {
                // Refresh leaderboard data when any course state changes occur
                _leaderboardBloc?.add(LoadUserRank(authState.user!.uid));
              }
            },
          ),
        ],
        child: Scaffold(
          appBar: AppBar(
            title: Text(_titles[_currentIndex]),
            centerTitle: true,
            actions: _currentIndex == 3
                ? [
                    IconButton(
                      icon: const Icon(Icons.logout),
                      onPressed: () {
                        _showLogoutDialog(context);
                      },
                    ),
                  ]
                : null,
          ),
          body: IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.school),
                label: 'Courses',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.leaderboard),
                label: 'Leaderboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<AuthBloc>().add(AuthLogoutRequested());
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
