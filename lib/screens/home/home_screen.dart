import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/course/course_bloc.dart';
import '../../blocs/course/course_event.dart';
import '../../blocs/course/course_state.dart';
import '../../blocs/leaderboard/leaderboard_bloc.dart';
import '../../blocs/leaderboard/leaderboard_event.dart';
import '../../blocs/leaderboard/leaderboard_state.dart';
import '../course/courses_list_screen.dart';
import '../leaderboard/leaderboard_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const HomeScreen());
  }

  @override
  Widget build(BuildContext context) {
    return const HomeContent();
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState.status == AuthStatus.authenticated &&
        authState.user != null) {
      context.read<LeaderboardBloc>().add(LoadUserRank(authState.user!.uid));
      context.read<CourseBloc>().add(LoadCourses());
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _WelcomeCard(),
          const SizedBox(height: 24),
          _StatsSection(),
          const SizedBox(height: 24),
          _QuickActionsSection(),
        ],
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.7),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Continue your learning journey',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Progress',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        BlocBuilder<LeaderboardBloc, LeaderboardState>(
          builder: (context, leaderboardState) {
            final userRank = leaderboardState.userRank;

            return BlocBuilder<CourseBloc, CourseState>(
              builder: (context, courseState) {
                final userPoints = userRank?.user.points ?? 0;
                final coursesCount = courseState.courses.length;

                return Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.star,
                        title: 'Points',
                        value: userPoints.toString(),
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.school,
                        title: 'Courses',
                        value: coursesCount.toString(),
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.emoji_events,
                        title: 'Rank',
                        value: userRank?.toString() ?? '-',
                        color: Colors.green,
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        GridView(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
              mainAxisExtent: 140),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _ActionCard(
              icon: Icons.play_circle_outline,
              title: 'Continue Learning',
              subtitle: 'Resume your progress',
              onTap: () {
                Navigator.of(context).push(CoursesListScreen.route());
              },
            ),
            _ActionCard(
              icon: Icons.leaderboard,
              title: 'Leaderboard',
              subtitle: 'See your ranking',
              onTap: () {
                Navigator.of(context).push(LeaderboardScreen.route());
              },
            ),
            _ActionCard(
              icon: Icons.person,
              title: 'Profile',
              subtitle: 'Manage account',
              onTap: () {
                Navigator.of(context).push(ProfileScreen.route());
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
