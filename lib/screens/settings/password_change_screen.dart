import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import '../../blocs/auth/password_change/password_change_bloc.dart';
import '../../repositories/auth_repository.dart';

class PasswordChangeScreen extends StatelessWidget {
  const PasswordChangeScreen({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
        builder: (_) => const PasswordChangeScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: BlocProvider(
          create: (context) => PasswordChangeBloc(
            authRepository: RepositoryProvider.of<AuthRepository>(context),
          ),
          child: const PasswordChangeForm(),
        ),
      ),
    );
  }
}

class PasswordChangeForm extends StatelessWidget {
  const PasswordChangeForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<PasswordChangeBloc, PasswordChangeState>(
      listener: (context, state) {
        if (state.status.isSuccess) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: const Text('Password changed successfully!'),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
            );
          Navigator.of(context).pop();
        }

        if (state.status.isFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content:
                    Text(state.errorMessage ?? 'Failed to change password'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
        }
      },
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.security,
                          color: Theme.of(context).colorScheme.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Change Your Password',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'For security, please enter your current password first',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 24),
                    _CurrentPasswordInput(),
                    const SizedBox(height: 16),
                    _NewPasswordInput(),
                    const SizedBox(height: 16),
                    _ConfirmPasswordInput(),
                    const SizedBox(height: 24),
                    _ChangePasswordButton(),
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

class _CurrentPasswordInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PasswordChangeBloc, PasswordChangeState>(
      buildWhen: (previous, current) =>
          previous.currentPassword != current.currentPassword,
      builder: (context, state) {
        return TextField(
          onChanged: (password) => context
              .read<PasswordChangeBloc>()
              .add(CurrentPasswordChanged(password)),
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Current Password',
            prefixIcon: const Icon(Icons.lock_outline),
            errorText: state.currentPassword.displayError != null
                ? 'Current password is required'
                : null,
            border: const OutlineInputBorder(),
          ),
        );
      },
    );
  }
}

class _NewPasswordInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PasswordChangeBloc, PasswordChangeState>(
      buildWhen: (previous, current) =>
          previous.newPassword != current.newPassword,
      builder: (context, state) {
        return TextField(
          onChanged: (password) => context
              .read<PasswordChangeBloc>()
              .add(NewPasswordChanged(password)),
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'New Password',
            prefixIcon: const Icon(Icons.lock),
            errorText: state.newPassword.displayError != null
                ? 'Password must be at least 6 characters'
                : null,
            border: const OutlineInputBorder(),
          ),
        );
      },
    );
  }
}

class _ConfirmPasswordInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PasswordChangeBloc, PasswordChangeState>(
      buildWhen: (previous, current) =>
          previous.confirmPassword != current.confirmPassword ||
          previous.newPassword != current.newPassword,
      builder: (context, state) {
        return TextField(
          onChanged: (password) => context
              .read<PasswordChangeBloc>()
              .add(ConfirmPasswordChanged(password)),
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Confirm New Password',
            prefixIcon: const Icon(Icons.lock),
            errorText:
                state.confirmPassword.value.isNotEmpty && !state.passwordsMatch
                    ? 'Passwords do not match'
                    : (state.confirmPassword.displayError != null
                        ? 'Password confirmation is required'
                        : null),
            border: const OutlineInputBorder(),
          ),
        );
      },
    );
  }
}

class _ChangePasswordButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PasswordChangeBloc, PasswordChangeState>(
      builder: (context, state) {
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: state.isValid &&
                    state.passwordsMatch &&
                    !state.status.isInProgress
                ? () => context
                    .read<PasswordChangeBloc>()
                    .add(PasswordChangeSubmitted())
                : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: state.status.isInProgress
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('CHANGE PASSWORD'),
          ),
        );
      },
    );
  }
}
