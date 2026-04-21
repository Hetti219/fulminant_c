import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:fulminant_c/blocs/course/course_bloc.dart';
import 'package:fulminant_c/blocs/course/course_event.dart';
import 'package:fulminant_c/blocs/course/course_state.dart';
import 'package:mockito/mockito.dart';

import '../helpers/mocks.mocks.dart';

void main() {
  late MockCourseRepository repo;
  late CourseBloc bloc;

  setUp(() {
    repo = MockCourseRepository();
    bloc = CourseBloc(courseRepository: repo);
  });

  tearDown(() => bloc.close());

  // ─── Error paths ───

  blocTest<CourseBloc, CourseState>(
    'LoadCourses → failure when getCourses throws',
    build: () {
      when(repo.getCourses()).thenThrow(Exception('network error'));
      return bloc;
    },
    act: (b) => b.add(LoadCourses()),
    expect: () => [
      isA<CourseState>()
          .having((s) => s.status, 'status', CourseStatus.loading),
      isA<CourseState>()
          .having((s) => s.status, 'status', CourseStatus.failure)
          .having(
              (s) => s.errorMessage, 'errorMessage', isNotNull),
    ],
  );

  blocTest<CourseBloc, CourseState>(
    'LoadCourse → failure when getCourse throws',
    build: () {
      when(repo.getCourse(any)).thenThrow(Exception('not found'));
      return bloc;
    },
    act: (b) => b.add(const LoadCourse('c_unknown')),
    expect: () => [
      isA<CourseState>()
          .having((s) => s.status, 'status', CourseStatus.loading),
      isA<CourseState>()
          .having((s) => s.status, 'status', CourseStatus.failure),
    ],
  );

  blocTest<CourseBloc, CourseState>(
    'LoadCourseModules → failure when getCourseModules throws',
    build: () {
      when(repo.getCourseModules(any))
          .thenThrow(Exception('failed to load modules'));
      return bloc;
    },
    act: (b) => b.add(const LoadCourseModules('c_prog')),
    expect: () => [
      isA<CourseState>()
          .having((s) => s.status, 'status', CourseStatus.loading),
      isA<CourseState>()
          .having((s) => s.status, 'status', CourseStatus.failure),
    ],
  );

  blocTest<CourseBloc, CourseState>(
    'LoadModule → failure when getModule throws',
    build: () {
      when(repo.getModule(any)).thenThrow(Exception('module not found'));
      return bloc;
    },
    act: (b) => b.add(const LoadModule('m_unknown')),
    expect: () => [
      isA<CourseState>()
          .having((s) => s.status, 'status', CourseStatus.loading),
      isA<CourseState>()
          .having((s) => s.status, 'status', CourseStatus.failure),
    ],
  );

  blocTest<CourseBloc, CourseState>(
    'CompleteModule → failure when completeModule throws',
    build: () {
      when(repo.completeModule(any, any, any))
          .thenThrow(Exception('server error'));
      return bloc;
    },
    act: (b) => b.add(const CompleteModule(
        userId: 'u_1', courseId: 'c_prog', moduleId: 'm_1')),
    expect: () => [
      isA<CourseState>()
          .having((s) => s.status, 'status', CourseStatus.failure)
          .having(
              (s) => s.errorMessage, 'errorMessage', isNotNull),
    ],
  );

  blocTest<CourseBloc, CourseState>(
    'CompleteActivity → failure when completeActivity throws',
    build: () {
      when(repo.completeActivity(any, any, any, any))
          .thenThrow(Exception('server error'));
      return bloc;
    },
    act: (b) => b.add(const CompleteActivity(
        userId: 'u_1',
        courseId: 'c_prog',
        moduleId: 'm_1',
        activityId: 'a_1')),
    expect: () => [
      isA<CourseState>()
          .having((s) => s.status, 'status', CourseStatus.failure)
          .having(
              (s) => s.errorMessage, 'errorMessage', isNotNull),
    ],
  );
}
