import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:fulminant_c/blocs/course/course_bloc.dart';
import 'package:fulminant_c/blocs/course/course_event.dart';
import 'package:fulminant_c/blocs/course/course_state.dart';
import 'package:mockito/mockito.dart';
import 'package:fulminant_c/models/course.dart' as models;
import '../helpers/mocks.mocks.dart';

void main() {
  late MockCourseRepository repo;
  late CourseBloc bloc;

  setUp(() {
    repo = MockCourseRepository();
    bloc = CourseBloc(courseRepository: repo);
  });

  tearDown(() => bloc.close());

// Load courses
  blocTest<CourseBloc, CourseState>(
    'LoadCourses → calls CourseRepository.getCourses()',
    build: () {
      when(repo.getCourses()).thenAnswer((_) async => <models.Course>[]);
      return bloc;
    },
    act: (b) => b.add(LoadCourses()),
    expect: () => [isA<CourseState>(), isA<CourseState>()],
    verify: (_) => verify(repo.getCourses()).called(1),
  );

// Load a single course
  blocTest<CourseBloc, CourseState>(
    'LoadCourse → calls CourseRepository.getCourse(id)',
    build: () {
      final c = MockCourse() as models.Course;
      when(repo.getCourse('c_prog')).thenAnswer((_) async => c);
      return bloc;
    },
    act: (b) => b.add(LoadCourse('c_prog')),
    expect: () => [isA<CourseState>(), isA<CourseState>()],
    verify: (_) => verify(repo.getCourse('c_prog')).called(1),
  );

// Load a single module
  blocTest<CourseBloc, CourseState>(
    'LoadModule → calls CourseRepository.getModule(id)',
    build: () {
      final m = MockModule() as models.Module;
      when(repo.getModule('m_1')).thenAnswer((_) async => m);
      return bloc;
    },
    act: (b) => b.add(LoadModule('m_1')),
    expect: () => [isA<CourseState>(), isA<CourseState>()],
    verify: (_) => verify(repo.getModule('m_1')).called(1),
  );

// Complete module
  blocTest<CourseBloc, CourseState>(
    'CompleteModule → calls CourseRepository.completeModule(...)',
    build: () {
      when(repo.completeModule(any, any, any, any)).thenAnswer((_) async {});
      return bloc;
    },
    act: (b) => b.add(CompleteModule(
        userId: 'u_1', courseId: 'c_prog', moduleId: 'm_1', points: 50)),
    expect: () => [isA<CourseState>(), isA<CourseState>()],
    verify: (_) =>
        verify(repo.completeModule('u_1', 'c_prog', 'm_1', 50)).called(1),
  );

// Complete activity
  blocTest<CourseBloc, CourseState>(
    'CompleteActivity → calls CourseRepository.completeActivity(...)',
    build: () {
      when(repo.completeActivity(any, any, any, any, any))
          .thenAnswer((_) async {});
      return bloc;
    },
    act: (b) => b.add(CompleteActivity(
        userId: 'u_1',
        courseId: 'c_prog',
        moduleId: 'm_1',
        activityId: 'a_42',
        points: 10)),
    expect: () => [isA<CourseState>(), isA<CourseState>()],
    verify: (_) =>
        verify(repo.completeActivity('u_1', 'c_prog', 'm_1', 'a_42', 10))
            .called(1),
  );
}
