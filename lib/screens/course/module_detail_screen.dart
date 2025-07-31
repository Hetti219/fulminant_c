import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/course/course_bloc.dart';
import '../../blocs/course/course_event.dart';
import '../../blocs/course/course_state.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../models/course.dart';
import '../../repositories/course_repository.dart';
import 'activity_screen.dart';

class ModuleDetailScreen extends StatelessWidget {
  final String moduleId;

  const ModuleDetailScreen({super.key, required this.moduleId});

  static Route<void> route(String moduleId) {
    return MaterialPageRoute<void>(
      builder: (_) => ModuleDetailScreen(moduleId: moduleId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final userId = authState.status == AuthStatus.authenticated ? authState.user?.uid : null;
    
    return BlocProvider(
      create: (context) => CourseBloc(
        courseRepository: RepositoryProvider.of<CourseRepository>(context),
      )..add(LoadModule(moduleId, userId: userId)),
      child: const ModuleDetailView(),
    );
  }
}

class ModuleDetailView extends StatelessWidget {
  const ModuleDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CourseBloc, CourseState>(
      builder: (context, state) {
        switch (state.status) {
          case CourseStatus.initial:
          case CourseStatus.loading:
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          case CourseStatus.failure:
            return Scaffold(
              appBar: AppBar(title: const Text('Module')),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load module',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.errorMessage ?? 'Unknown error occurred',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          case CourseStatus.success:
            if (state.selectedModule == null) {
              return const Scaffold(
                body: Center(child: Text('Module not found')),
              );
            }
            return _ModuleDetailContent(module: state.selectedModule!);
        }
      },
    );
  }
}

class _ModuleDetailContent extends StatelessWidget {
  final Module module;

  const _ModuleDetailContent({required this.module});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(module.title),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ModuleInfo(module: module),
            const SizedBox(height: 24),
            _ModuleContent(content: module.content),
            const SizedBox(height: 24),
            if (module.activities.isNotEmpty) ...[
              _ActivitiesSection(activities: module.activities, module: module),
              const SizedBox(height: 24),
            ],
            _CompleteModuleButton(module: module),
          ],
        ),
      ),
    );
  }
}

class _ModuleInfo extends StatelessWidget {
  final Module module;

  const _ModuleInfo({required this.module});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.menu_book,
              size: 48,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    module.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 16,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${module.pointsReward} points',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.quiz_outlined,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${module.activities.length} activities',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
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

class _ModuleContent extends StatelessWidget {
  final String content;

  const _ModuleContent({required this.content});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Content',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivitiesSection extends StatelessWidget {
  final List<Activity> activities;
  final Module module;

  const _ActivitiesSection({
    required this.activities,
    required this.module,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Activities',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...activities.map((activity) => _ActivityCard(
              activity: activity,
              module: module,
            )),
      ],
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final Activity activity;
  final Module module;

  const _ActivityCard({
    required this.activity,
    required this.module,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CourseBloc, CourseState>(
      builder: (context, courseState) {
        // Check if activity is completed
        final isCompleted = courseState.userProgress.any(
          (progress) => progress.activityId == activity.id && 
                       progress.isCompleted
        );

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: isCompleted 
                    ? Colors.grey 
                    : _getActivityColor(activity.type),
                child: Icon(
                  isCompleted 
                      ? Icons.check_circle 
                      : _getActivityIcon(activity.type),
                  color: Colors.white,
                ),
              ),
              title: Text(
                activity.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isCompleted ? Colors.grey : null,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    isCompleted 
                        ? 'Completed'
                        : _getActivityDescription(activity.type),
                    style: TextStyle(
                      color: isCompleted ? Colors.grey : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 14,
                        color: isCompleted ? Colors.grey : Colors.orange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${activity.pointsReward} points',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isCompleted ? Colors.grey : Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: Icon(
                isCompleted ? Icons.lock : Icons.chevron_right,
                color: isCompleted ? Colors.grey : null,
              ),
              onTap: isCompleted ? null : () {
                final courseBloc = context.read<CourseBloc>();
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => BlocProvider.value(
                      value: courseBloc,
                      child: ActivityScreen(activity: activity, module: module),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Color _getActivityColor(ActivityType type) {
    switch (type) {
      case ActivityType.quiz:
        return Colors.blue;
      case ActivityType.questionnaire:
        return Colors.green;
    }
  }

  IconData _getActivityIcon(ActivityType type) {
    switch (type) {
      case ActivityType.quiz:
        return Icons.quiz;
      case ActivityType.questionnaire:
        return Icons.assignment;
    }
  }

  String _getActivityDescription(ActivityType type) {
    switch (type) {
      case ActivityType.quiz:
        return 'Test your knowledge with multiple choice questions';
      case ActivityType.questionnaire:
        return 'Answer survey questions to reflect on the content';
    }
  }
}

class _CompleteModuleButton extends StatelessWidget {
  final Module module;

  const _CompleteModuleButton({required this.module});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState.status != AuthStatus.authenticated) {
          return const SizedBox.shrink();
        }

        return BlocBuilder<CourseBloc, CourseState>(
          builder: (context, courseState) {
            // Check if module is already completed
            final isCompleted = courseState.userProgress.any(
              (progress) => progress.moduleId == module.id && 
                           progress.activityId == null && 
                           progress.isCompleted
            );

            return SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isCompleted ? null : () {
                  _showCompleteModuleDialog(context, authState.user!.uid);
                },
                icon: Icon(isCompleted ? Icons.check_circle : Icons.check_circle_outline),
                label: Text(isCompleted ? 'Completed' : 'Mark as Complete'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: isCompleted ? Colors.grey : Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showCompleteModuleDialog(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Complete Module'),
          content: Text(
            'Are you sure you want to mark "${module.title}" as complete? '
            'You will earn ${module.pointsReward} points.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<CourseBloc>().add(
                  CompleteModule(
                    userId: userId,
                    courseId: module.courseId,
                    moduleId: module.id,
                    points: module.pointsReward,
                  ),
                );
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Module completed! You earned ${module.pointsReward} points.',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Complete'),
            ),
          ],
        );
      },
    );
  }
}