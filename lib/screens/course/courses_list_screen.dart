import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/course/course_bloc.dart';
import '../../blocs/course/course_event.dart';
import '../../blocs/course/course_state.dart';
import '../../models/course.dart';
import '../../repositories/course_repository.dart';
import 'course_detail_screen.dart';

class CoursesListScreen extends StatelessWidget {
  final bool showScaffold;

  const CoursesListScreen({super.key, this.showScaffold = false});

  static Route<void> route() {
    return MaterialPageRoute<void>(
        builder: (_) => const CoursesListScreen(showScaffold: true));
  }

  @override
  Widget build(BuildContext context) {
    final courseBlocProvider = BlocProvider(
      create: (context) => CourseBloc(
        courseRepository: RepositoryProvider.of<CourseRepository>(context),
      )..add(LoadCourses()),
      child: const CoursesListView(),
    );

    if (showScaffold) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Courses'),
        ),
        body: courseBlocProvider,
      );
    } else {
      return courseBlocProvider;
    }
  }
}

class CoursesListView extends StatelessWidget {
  const CoursesListView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CourseBloc, CourseState>(
      builder: (context, state) {
        switch (state.status) {
          case CourseStatus.initial:
          case CourseStatus.loading:
            return const Center(child: CircularProgressIndicator());
          case CourseStatus.failure:
            return Center(
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
                    'Failed to load courses',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.errorMessage ?? 'Unknown error occurred',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<CourseBloc>().add(LoadCourses());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          case CourseStatus.success:
            if (state.courses.isEmpty) {
              return _EmptyCoursesView();
            }
            return _CoursesGrid(courses: state.courses);
        }
      },
    );
  }
}

class _EmptyCoursesView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.school_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'No Courses Available',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Courses will appear here once they are added.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.read<CourseBloc>().add(LoadCourses());
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
          ),
        ],
      ),
    );
  }
}

class _CoursesGrid extends StatelessWidget {
  final List<Course> courses;

  const _CoursesGrid({required this.courses});

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.of(context).textScaler.scale(1.0);
    // Base height + a bit extra if the user has larger fonts enabled.
    final tileHeight = 280.0 + (textScale - 1.0) * 80.0;

    return RefreshIndicator(
      onRefresh: () async {
        context.read<CourseBloc>().add(LoadCourses());
      },
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          mainAxisExtent: tileHeight,
        ),
        itemCount: courses.length,
        itemBuilder: (context, index) {
          final course = courses[index];
          return _CourseCard(course: course);
        },
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final Course course;

  const _CourseCard({required this.course});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            CourseDetailScreen.route(course.id),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.1),
                ),
                child: course.imageUrl.isNotEmpty
                    ? Image.network(
                        course.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _DefaultCourseImage(),
                      )
                    : _DefaultCourseImage(),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // FIX: Let title size itself up to 2 lines (no Flexible here),
                    // so it isn't squeezed by other Flexible/Spacer siblings.
                    Text(
                      course.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                    ),
                    const SizedBox(height: 6),

                    // Use Expanded on description to occupy remaining space,
                    // keeping the bottom row pinned to the card bottom.
                    Expanded(
                      child: Text(
                        course.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                      ),
                    ),

                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.book_outlined,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${course.moduleIds.length} modules',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DefaultCourseImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Icon(
        Icons.school,
        size: 48,
        color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
      ),
    );
  }
}
