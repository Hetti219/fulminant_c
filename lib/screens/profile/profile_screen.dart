import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/course_repository.dart';
import '../../models/user.dart' as app_user;
import '../../models/course.dart';
import '../settings/settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  final bool showScaffold;

  const ProfileScreen({super.key, this.showScaffold = false});

  static Route<void> route() {
    return MaterialPageRoute<void>(
        builder: (_) => const ProfileScreen(showScaffold: true));
  }

  @override
  Widget build(BuildContext context) {
    if (showScaffold) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
        ),
        body: const ProfileView(),
      );
    } else {
      return const ProfileView();
    }
  }
}

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  app_user.User? _user;
  List<UserProgress>? _userProgress;
  List<Course>? _courses;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final authState = context.read<AuthBloc>().state;
    if (authState.status == AuthStatus.authenticated &&
        authState.user != null) {
      try {
        final authRepository = RepositoryProvider.of<AuthRepository>(context);
        final courseRepository =
            RepositoryProvider.of<CourseRepository>(context);

        // Load user data and progress in parallel
        final results = await Future.wait([
          authRepository.getUserData(authState.user!.uid),
          courseRepository.getUserProgress(authState.user!.uid),
          courseRepository.getCourses(),
        ]);

        setState(() {
          _user = results[0] as app_user.User;
          _userProgress = results[1] as List<UserProgress>;
          _courses = results[2] as List<Course>;
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to load profile: ${e.toString()}'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _user == null
            ? const _ProfileErrorView()
            : _ProfileContent(
                user: _user!,
                userProgress: _userProgress ?? [],
                courses: _courses ?? [],
              );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class _ProfileContent extends StatelessWidget {
  final app_user.User user;
  final List<UserProgress> userProgress;
  final List<Course> courses;

  const _ProfileContent({
    required this.user,
    required this.userProgress,
    required this.courses,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _ProfileHeader(user: user),
          const SizedBox(height: 24),
          _ProfileStats(
            user: user,
            userProgress: userProgress,
            courses: courses,
          ),
          const SizedBox(height: 24),
          _ProfileDetails(user: user),
          const SizedBox(height: 24),
          _ProfileActions(user: user),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final app_user.User user;

  const _ProfileHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user.fullName,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              user.email,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star,
                    color: Theme.of(context).colorScheme.tertiary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${user.points} points',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onTertiaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileStats extends StatelessWidget {
  final app_user.User user;
  final List<UserProgress> userProgress;
  final List<Course> courses;

  const _ProfileStats({
    required this.user,
    required this.userProgress,
    required this.courses,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate stats from user progress
    final uniqueCourses =
        userProgress.map((progress) => progress.courseId).toSet().length;

    final completedActivities = userProgress
        .where(
            (progress) => progress.activityId != null && progress.isCompleted)
        .length;

    final completedModules = userProgress
        .where(
            (progress) => progress.activityId == null && progress.isCompleted)
        .length;

    // Total completed items (activities + modules)
    final totalCompleted = completedActivities + completedModules;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.school,
            title: 'Courses',
            value: uniqueCourses.toString(),
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatCard(
            icon: Icons.check_circle,
            title: 'Completed',
            value: totalCompleted.toString(),
            color: Theme.of(context).colorScheme.secondary,
          ),
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
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileDetails extends StatelessWidget {
  final app_user.User user;

  const _ProfileDetails({required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personal Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _DetailRow(
              icon: Icons.person,
              label: 'Full Name',
              value: user.fullName,
            ),
            const SizedBox(height: 12),
            _DetailRow(
              icon: Icons.email,
              label: 'Email',
              value: user.email,
            ),
            const SizedBox(height: 12),
            _DetailRow(
              icon: Icons.cake,
              label: 'Date of Birth',
              value: DateFormat('MMM dd, yyyy').format(user.dateOfBirth),
            ),
            const SizedBox(height: 12),
            _DetailRow(
              icon: Icons.calendar_today,
              label: 'Member Since',
              value: DateFormat('MMM dd, yyyy').format(user.createdAt),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileActions extends StatelessWidget {
  final app_user.User user;

  const _ProfileActions({required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              _showEditProfileDialog(context);
            },
            icon: const Icon(Icons.edit),
            label: const Text('Edit Profile'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).push(SettingsScreen.route());
            },
            icon: const Icon(Icons.settings),
            label: const Text('Settings'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final nameController = TextEditingController(text: user.fullName);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Email: ${user.email}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Email cannot be changed',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newName = nameController.text.trim();
                if (newName.isNotEmpty && newName != user.fullName) {
                  try {
                    final authRepository =
                        RepositoryProvider.of<AuthRepository>(context);
                    await authRepository.updateUserProfile(user.id, newName);

                    Navigator.of(dialogContext.mounted as BuildContext).pop();
                    ScaffoldMessenger.of(context.mounted as BuildContext)
                        .showSnackBar(
                      SnackBar(
                        content: Text('Profile updated successfully!'),
                        backgroundColor:
                            Theme.of(context.mounted as BuildContext)
                                .colorScheme
                                .secondary,
                      ),
                    );

                    // Refresh the profile data
                    if (context.mounted) {
                      final profileState =
                          context.findAncestorStateOfType<_ProfileViewState>();
                      profileState?._loadUserData();
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context.mounted as BuildContext)
                        .showSnackBar(
                      SnackBar(
                        content:
                            Text('Failed to update profile: ${e.toString()}'),
                        backgroundColor:
                            Theme.of(context.mounted as BuildContext)
                                .colorScheme
                                .error,
                      ),
                    );
                  }
                } else {
                  Navigator.of(dialogContext).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}

class _ProfileErrorView extends StatelessWidget {
  const _ProfileErrorView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load profile',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Please try again or contact support.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }
}
