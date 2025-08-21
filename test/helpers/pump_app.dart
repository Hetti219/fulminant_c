import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pumpApp(
  WidgetTester tester, {
  required Widget child,
  List<RepositoryProvider> repositories = const [],
  List<BlocProvider> blocs = const [],
}) async {
  Widget tree = child;

  if (blocs.isNotEmpty) {
    tree = MultiBlocProvider(providers: blocs, child: tree);
  }
  if (repositories.isNotEmpty) {
    tree = MultiRepositoryProvider(providers: repositories, child: tree);
  }

  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(body: tree),
    ),
  );
  await tester.pumpAndSettle();
}
