import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:fulminant_c/blocs/auth/auth_bloc.dart';
import 'package:fulminant_c/blocs/auth/auth_event.dart';
import 'package:fulminant_c/blocs/auth/auth_state.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart' as fa;

import '../helpers/mocks.mocks.dart';

void main() {
  late MockAuthRepository auth;
  late AuthBloc bloc;

  setUp(() {
    auth = MockAuthRepository();
// NOTE: Intentionally no stub like `when(auth.userChanges())...` because
// your AuthRepository interface doesn't define it.
    bloc = AuthBloc(authRepository: auth);
  });

  tearDown(() => bloc.close());

  blocTest<AuthBloc, AuthState>(
    'invokes signOut on AuthLogoutRequested',
    build: () => bloc,
    act: (b) => b.add(AuthLogoutRequested()),
    verify: (_) => verify(auth.signOut()).called(1),
  );

// If your AuthBloc exposes an AuthUserChanged event with a user payload and
// you want coverage for it, share the event signature and target state and
// we can add a second test using a generated MockUser.
}
