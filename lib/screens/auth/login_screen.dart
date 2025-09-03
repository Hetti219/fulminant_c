import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import '../../blocs/auth/login/login_bloc.dart';
import '../../blocs/auth/login/login_event.dart';
import '../../blocs/auth/login/login_state.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/biometric_service.dart';
import 'signup_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const LoginScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: BlocProvider(
          create: (context) => LoginBloc(
            authRepository: RepositoryProvider.of<AuthRepository>(context),
            biometricService: RepositoryProvider.of<BiometricService>(context),
          ),
          child: const LoginForm(),
        ),
      ),
    );
  }
}

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        // Handle regular login failures
        if (state.status.isFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Authentication Failure'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
        }

        // Handle password reset success/failure
        if (state.isPasswordResetSuccess) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content:
                    const Text('Password reset email sent! Check your inbox.'),
                backgroundColor: Theme.of(context).colorScheme.primary,
                duration: const Duration(seconds: 4),
              ),
            );
        }

        if (state.passwordResetError != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.passwordResetError!),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
        }

        // Handle biometric authentication errors
        if (state.biometricAuthError != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.biometricAuthError!),
                backgroundColor: Theme.of(context).colorScheme.error,
                action: SnackBarAction(
                  label: 'Retry',
                  onPressed: () => context
                      .read<LoginBloc>()
                      .add(BiometricAuthenticationRequested()),
                ),
              ),
            );
        }
      },
      child: Align(
        alignment: const Alignment(0, -1 / 3),
        child: SingleChildScrollView(
          child: BlocBuilder<LoginBloc, LoginState>(
            builder: (context, state) {
              // Show biometric authentication screen if required
              if (state.requiresBiometricAuth) {
                return _BiometricAuthScreen();
              }

              // Show regular login form
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/logo-res.png',
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 48),
                  _EmailInput(),
                  const SizedBox(height: 16),
                  _PasswordInput(),
                  const SizedBox(height: 8),
                  _ForgotPasswordButton(),
                  const SizedBox(height: 24),
                  _LoginButton(),
                  const SizedBox(height: 16),
                  _SignUpButton(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// NEW: Biometric Authentication Screen
class _BiometricAuthScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/logo-res.png',
              width: 150,
              height: 150,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 32),
            Icon(
              Icons.fingerprint,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Biometric Authentication Required',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Please verify your identity using your fingerprint, face, or device PIN',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (state.isBiometricAuthInProgress)
              const CircularProgressIndicator()
            else
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => context
                          .read<LoginBloc>()
                          .add(BiometricAuthenticationRequested()),
                      icon: const Icon(Icons.fingerprint),
                      label: const Text('Authenticate'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      // Sign out and return to login form
                      context.read<AuthRepository>().signOut();
                    },
                    child: const Text('Cancel & Sign Out'),
                  ),
                ],
              ),
          ],
        );
      },
    );
  }
}

class _EmailInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      buildWhen: (previous, current) => previous.email != current.email,
      builder: (context, state) {
        return TextField(
          key: const Key('loginForm_emailInput_textField'),
          onChanged: (email) =>
              context.read<LoginBloc>().add(LoginEmailChanged(email)),
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Email',
            prefixIcon: const Icon(Icons.email),
            errorText:
                state.email.displayError != null ? 'Invalid email' : null,
            border: const OutlineInputBorder(),
          ),
        );
      },
    );
  }
}

class _PasswordInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      buildWhen: (previous, current) => previous.password != current.password,
      builder: (context, state) {
        return TextField(
          key: const Key('loginForm_passwordInput_textField'),
          onChanged: (password) =>
              context.read<LoginBloc>().add(LoginPasswordChanged(password)),
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Password',
            prefixIcon: const Icon(Icons.lock),
            errorText: state.password.displayError != null
                ? 'Password must be at least 6 characters'
                : null,
            border: const OutlineInputBorder(),
          ),
        );
      },
    );
  }
}

class _ForgotPasswordButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        return Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: state.isPasswordResetInProgress
                ? null
                : () => _showForgotPasswordDialog(context),
            child: state.isPasswordResetInProgress
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Forgot Password?'),
          ),
        );
      },
    );
  }

  void _showForgotPasswordDialog(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final loginBloc = context.read<LoginBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: loginBloc,
        child: AlertDialog(
          title: const Text('Reset Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Enter your email address and we\'ll send you a link to reset your password.',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            BlocBuilder<LoginBloc, LoginState>(
              builder: (blocContext, state) {
                return ElevatedButton(
                  onPressed: state.isPasswordResetInProgress
                      ? null
                      : () {
                          final email = emailController.text.trim();
                          if (email.isNotEmpty) {
                            loginBloc.add(PasswordResetRequested(email));
                            Navigator.of(dialogContext).pop();
                          }
                        },
                  child: state.isPasswordResetInProgress
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Send Reset Email'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        return state.status.isInProgress
            ? const CircularProgressIndicator()
            : SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  key: const Key('loginForm_continue_raisedButton'),
                  onPressed: state.isValid
                      ? () => context.read<LoginBloc>().add(LoginSubmitted())
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('LOGIN'),
                ),
              );
      },
    );
  }
}

class _SignUpButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      key: const Key('loginForm_createAccount_flatButton'),
      onPressed: () => Navigator.of(context).push<void>(SignupScreen.route()),
      child: const Text('CREATE ACCOUNT'),
    );
  }
}
