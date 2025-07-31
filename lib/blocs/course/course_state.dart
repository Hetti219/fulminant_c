import 'package:equatable/equatable.dart';
import '../../models/course.dart';

enum CourseStatus { initial, loading, success, failure }

class CourseState extends Equatable {
  final CourseStatus status;
  final List<Course> courses;
  final Course? selectedCourse;
  final List<Module> modules;
  final Module? selectedModule;
  final List<UserProgress> userProgress;
  final String? errorMessage;

  const CourseState({
    this.status = CourseStatus.initial,
    this.courses = const [],
    this.selectedCourse,
    this.modules = const [],
    this.selectedModule,
    this.userProgress = const [],
    this.errorMessage,
  });

  CourseState copyWith({
    CourseStatus? status,
    List<Course>? courses,
    Course? selectedCourse,
    List<Module>? modules,
    Module? selectedModule,
    List<UserProgress>? userProgress,
    String? errorMessage,
  }) {
    return CourseState(
      status: status ?? this.status,
      courses: courses ?? this.courses,
      selectedCourse: selectedCourse ?? this.selectedCourse,
      modules: modules ?? this.modules,
      selectedModule: selectedModule ?? this.selectedModule,
      userProgress: userProgress ?? this.userProgress,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        courses,
        selectedCourse,
        modules,
        selectedModule,
        userProgress,
        errorMessage,
      ];
}