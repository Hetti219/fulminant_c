import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/course/course_bloc.dart';
import '../../blocs/course/course_event.dart';
import '../../blocs/course/course_state.dart';
import '../../models/course.dart';
import '../../repositories/course_repository.dart';
import 'module_detail_screen.dart';

class CourseDetailScreen extends StatelessWidget {
  final String courseId;

  const CourseDetailScreen({super.key, required this.courseId});

  static Route<void> route(String courseId) {
    return MaterialPageRoute<void>(
      builder: (_) => CourseDetailScreen(courseId: courseId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CourseBloc(
        courseRepository: RepositoryProvider.of<CourseRepository>(context),
      )..add(LoadCourse(courseId))..add(LoadCourseModules(courseId)),
      child: const CourseDetailView(),
    );
  }
}

class CourseDetailView extends StatelessWidget {
  const CourseDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<CourseBloc, CourseState>(
        builder: (context, state) {
          switch (state.status) {
            case CourseStatus.initial:
            case CourseStatus.loading:
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            case CourseStatus.failure:
              return Scaffold(
                appBar: AppBar(title: const Text('Course')),
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
                        'Failed to load course',
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
              if (state.selectedCourse == null) {
                return const Scaffold(
                  body: Center(child: Text('Course not found')),
                );
              }
              return _CourseDetailContent(
                course: state.selectedCourse!,
                modules: state.modules,
              );
          }
        },
      ),
    );
  }
}

class _CourseDetailContent extends StatelessWidget {
  final Course course;
  final List<Module> modules;

  const _CourseDetailContent({
    required this.course,
    required this.modules,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              course.title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.8),
                  ],
                ),
              ),
              child: course.imageUrl.isNotEmpty
                  ? Image.network(
                      course.imageUrl,
                      fit: BoxFit.cover,
                    )
                  : Icon(
                      Icons.school,
                      size: 80,
                      color: Colors.white.withOpacity(0.7),
                    ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CourseInfo(course: course, moduleCount: modules.length),
                const SizedBox(height: 24),
                Text(
                  'Modules',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        if (modules.isEmpty)
          const SliverToBoxAdapter(
            child: _EmptyModulesView(),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final module = modules[index];
                return _ModuleCard(
                  module: module,
                  index: index,
                );
              },
              childCount: modules.length,
            ),
          ),
      ],
    );
  }
}

class _CourseInfo extends StatelessWidget {
  final Course course;
  final int moduleCount;

  const _CourseInfo({
    required this.course,
    required this.moduleCount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Course Description',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              course.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _InfoChip(
                  icon: Icons.book_outlined,
                  label: '$moduleCount modules',
                ),
                const SizedBox(width: 8),
                _InfoChip(
                  icon: Icons.schedule,
                  label: 'Self-paced',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
    );
  }
}

class _EmptyModulesView extends StatelessWidget {
  const _EmptyModulesView();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.menu_book_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No Modules Yet',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Modules for this course will appear here once they are added.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final Module module;
  final int index;

  const _ModuleCard({
    required this.module,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor,
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            module.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                module.content.length > 100
                    ? '${module.content.substring(0, 100)}...'
                    : module.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
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
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.of(context).push(
              ModuleDetailScreen.route(module.id),
            );
          },
        ),
      ),
    );
  }
}