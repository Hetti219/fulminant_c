import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/course.dart';
import '../../repositories/course_repository.dart';
import 'course_event.dart';
import 'course_state.dart';

class CourseBloc extends Bloc<CourseEvent, CourseState> {
  final CourseRepository _courseRepository;

  CourseBloc({required CourseRepository courseRepository})
      : _courseRepository = courseRepository,
        super(const CourseState()) {
    on<LoadCourses>(_onLoadCourses);
    on<LoadCourse>(_onLoadCourse);
    on<LoadCourseModules>(_onLoadCourseModules);
    on<LoadModule>(_onLoadModule);
    on<CompleteModule>(_onCompleteModule);
    on<CompleteActivity>(_onCompleteActivity);
  }

  void _onLoadCourses(LoadCourses event, Emitter<CourseState> emit) async {
    emit(state.copyWith(status: CourseStatus.loading));
    try {
      final courses = await _courseRepository.getCourses();
      emit(state.copyWith(
        status: CourseStatus.success,
        courses: courses,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: CourseStatus.failure,
        errorMessage: error.toString(),
      ));
    }
  }

  void _onLoadCourse(LoadCourse event, Emitter<CourseState> emit) async {
    emit(state.copyWith(status: CourseStatus.loading));
    try {
      final course = await _courseRepository.getCourse(event.courseId);
      emit(state.copyWith(
        status: CourseStatus.success,
        selectedCourse: course,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: CourseStatus.failure,
        errorMessage: error.toString(),
      ));
    }
  }

  void _onLoadCourseModules(LoadCourseModules event, Emitter<CourseState> emit) async {
    emit(state.copyWith(status: CourseStatus.loading));
    try {
      final modules = await _courseRepository.getCourseModules(event.courseId);
      emit(state.copyWith(
        status: CourseStatus.success,
        modules: modules,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: CourseStatus.failure,
        errorMessage: error.toString(),
      ));
    }
  }

  void _onLoadModule(LoadModule event, Emitter<CourseState> emit) async {
    emit(state.copyWith(status: CourseStatus.loading));
    try {
      final module = await _courseRepository.getModule(event.moduleId);
      
      // Load user progress if userId is provided
      List<UserProgress> userProgress = state.userProgress;
      if (event.userId != null) {
        userProgress = await _courseRepository.getUserProgress(event.userId!);
      }
      
      emit(state.copyWith(
        status: CourseStatus.success,
        selectedModule: module,
        userProgress: userProgress,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: CourseStatus.failure,
        errorMessage: error.toString(),
      ));
    }
  }

  void _onCompleteModule(CompleteModule event, Emitter<CourseState> emit) async {
    try {
      await _courseRepository.completeModule(
        event.userId,
        event.courseId,
        event.moduleId,
        event.points,
      );
      
      // Reload user progress
      final userProgress = await _courseRepository.getUserProgress(event.userId);
      emit(state.copyWith(userProgress: userProgress));
    } catch (error) {
      emit(state.copyWith(
        status: CourseStatus.failure,
        errorMessage: error.toString(),
      ));
    }
  }

  void _onCompleteActivity(CompleteActivity event, Emitter<CourseState> emit) async {
    try {
      await _courseRepository.completeActivity(
        event.userId,
        event.courseId,
        event.moduleId,
        event.activityId,
        event.points,
      );
      
      // Reload user progress
      final userProgress = await _courseRepository.getUserProgress(event.userId);
      emit(state.copyWith(userProgress: userProgress));
    } catch (error) {
      emit(state.copyWith(
        status: CourseStatus.failure,
        errorMessage: error.toString(),
      ));
    }
  }
}