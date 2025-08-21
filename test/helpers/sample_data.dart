class SampleUser {
  final String id;
  final String email;
  final String name;

  const SampleUser({required this.id, required this.email, required this.name});
}

const tUser = SampleUser(id: 'u_1', email: 'sakura@leaf.dev', name: 'Sakura');

class SampleCourse {
  final String id;
  final String title;

  const SampleCourse(this.id, this.title);
}

const tCourse = SampleCourse('c_prog', 'Basics of Programming');

class SampleModule {
  final String id;
  final String courseId;
  final int points;

  const SampleModule(this.id, this.courseId, this.points);
}

const tModule = SampleModule('m_1', 'c_prog', 50);
