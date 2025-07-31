import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/course/course_bloc.dart';
import '../../blocs/course/course_event.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/course/course_state.dart';
import '../../models/course.dart';

class ActivityScreen extends StatefulWidget {
  final Activity activity;
  final Module module;

  const ActivityScreen({
    super.key,
    required this.activity,
    required this.module,
  });

  static Route<void> route(Activity activity, Module module) {
    return MaterialPageRoute<void>(
      builder: (_) => ActivityScreen(activity: activity, module: module),
    );
  }

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  final Map<String, dynamic> _answers = {};
  bool _isCompleted = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CourseBloc, CourseState>(
      builder: (context, courseState) {
        // Check if activity is already completed in the database
        final isAlreadyCompleted = courseState.userProgress.any((progress) =>
            progress.activityId == widget.activity.id && progress.isCompleted);

        return Scaffold(
          appBar: AppBar(
            title: Text(widget.activity.title),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _activityInfo(),
                const SizedBox(height: 24),
                if (isAlreadyCompleted)
                  _alreadyCompletedMessage()
                else ...[
                  _activityContent(),
                  const SizedBox(height: 24),
                  if (!_isCompleted) _completeActivityButton(),
                  if (_isCompleted) _completionMessage(),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _activityInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: _getActivityColor(),
              child: Icon(
                _getActivityIcon(),
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.activity.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getActivityTypeString(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
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
                        '${widget.activity.pointsReward} points',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
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

  Widget _activityContent() {
    switch (widget.activity.type) {
      case ActivityType.quiz:
        return _quizContent();
      case ActivityType.questionnaire:
        return _questionnaireContent();
    }
  }

  Widget _quizContent() {
    final questions = widget.activity.data['questions'] as List<dynamic>? ?? [];

    if (questions.isEmpty) {
      return _emptyActivityContent('No quiz questions available');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quiz Questions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        ...questions.asMap().entries.map((entry) {
          final index = entry.key;
          final question = entry.value as Map<String, dynamic>;
          return _QuizQuestion(
            question: question,
            questionIndex: index,
            selectedAnswer: _answers['question_$index'] as String?,
            onAnswerChanged: (answer) {
              setState(() {
                _answers['question_$index'] = answer;
              });
            },
          );
        }),
      ],
    );
  }

  Widget _questionnaireContent() {
    final questions = widget.activity.data['questions'] as List<dynamic>? ?? [];

    if (questions.isEmpty) {
      return _emptyActivityContent('No questionnaire items available');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Questionnaire',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        ...questions.asMap().entries.map((entry) {
          final index = entry.key;
          final question = entry.value as Map<String, dynamic>;
          return _QuestionnaireItem(
            question: question,
            questionIndex: index,
            onAnswerChanged: (answer) {
              setState(() {
                _answers['question_$index'] = answer;
              });
            },
          );
        }),
      ],
    );
  }

  Widget _emptyActivityContent(String message) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.quiz_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
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

  Widget _completeActivityButton() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState.status != AuthStatus.authenticated) {
          return const SizedBox.shrink();
        }

        final canComplete = _canCompleteActivity();

        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: canComplete
                ? () => _completeActivity(authState.user!.uid)
                : null,
            icon: const Icon(Icons.check_circle),
            label: const Text('Complete Activity'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        );
      },
    );
  }

  Widget _completionMessage() {
    return Card(
      color: Colors.green.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Activity Completed!',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    'You earned ${widget.activity.pointsReward} points.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.green,
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

  Widget _alreadyCompletedMessage() {
    return Card(
      color: Colors.blue.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.blue,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                'Activity Already Completed',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'You have already completed this activity and earned ${widget.activity.pointsReward} points.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.blue,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Go Back'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getActivityColor() {
    switch (widget.activity.type) {
      case ActivityType.quiz:
        return Colors.blue;
      case ActivityType.questionnaire:
        return Colors.green;
    }
  }

  IconData _getActivityIcon() {
    switch (widget.activity.type) {
      case ActivityType.quiz:
        return Icons.quiz;
      case ActivityType.questionnaire:
        return Icons.assignment;
    }
  }

  String _getActivityTypeString() {
    switch (widget.activity.type) {
      case ActivityType.quiz:
        return 'Multiple Choice Quiz';
      case ActivityType.questionnaire:
        return 'Questionnaire';
    }
  }

  bool _canCompleteActivity() {
    final questions = widget.activity.data['questions'] as List<dynamic>? ?? [];
    if (questions.isEmpty) return true;

    for (int i = 0; i < questions.length; i++) {
      if (!_answers.containsKey('question_$i')) {
        return false;
      }
    }
    return true;
  }

  void _completeActivity(String userId) {
    context.read<CourseBloc>().add(
          CompleteActivity(
            userId: userId,
            courseId: widget.module.courseId,
            moduleId: widget.module.id,
            activityId: widget.activity.id,
            points: widget.activity.pointsReward,
          ),
        );

    setState(() {
      _isCompleted = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Activity completed! You earned ${widget.activity.pointsReward} points.',
        ),
        backgroundColor: Colors.green,
      ),
    );
  }
}

class _QuizQuestion extends StatelessWidget {
  final Map<String, dynamic> question;
  final int questionIndex;
  final String? selectedAnswer;
  final Function(String) onAnswerChanged;

  const _QuizQuestion({
    required this.question,
    required this.questionIndex,
    required this.selectedAnswer,
    required this.onAnswerChanged,
  });

  @override
  Widget build(BuildContext context) {
    final questionText = question['question'] as String? ?? '';
    final options = question['options'] as List<dynamic>? ?? [];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question ${questionIndex + 1}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              questionText,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            ...options.asMap().entries.map((entry) {
              final option = entry.value as String;
              return RadioListTile<String>(
                title: Text(option),
                value: option,
                groupValue: selectedAnswer,
                onChanged: (value) {
                  if (value != null) {
                    onAnswerChanged(value);
                  }
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _QuestionnaireItem extends StatelessWidget {
  final Map<String, dynamic> question;
  final int questionIndex;
  final Function(String) onAnswerChanged;

  const _QuestionnaireItem({
    required this.question,
    required this.questionIndex,
    required this.onAnswerChanged,
  });

  @override
  Widget build(BuildContext context) {
    final questionText = question['question'] as String? ?? '';
    final type = question['type'] as String? ?? 'text';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question ${questionIndex + 1}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              questionText,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            if (type == 'text')
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Enter your answer...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                onChanged: onAnswerChanged,
              )
            else if (type == 'rating')
              _RatingWidget(onChanged: onAnswerChanged),
          ],
        ),
      ),
    );
  }
}

class _RatingWidget extends StatefulWidget {
  final Function(String) onChanged;

  const _RatingWidget({required this.onChanged});

  @override
  State<_RatingWidget> createState() => _RatingWidgetState();
}

class _RatingWidgetState extends State<_RatingWidget> {
  int _rating = 0;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (index) {
        return IconButton(
          onPressed: () {
            setState(() {
              _rating = index + 1;
            });
            widget.onChanged(_rating.toString());
          },
          icon: Icon(
            index < _rating ? Icons.star : Icons.star_border,
            color: Colors.orange,
            size: 32,
          ),
        );
      }),
    );
  }
}
