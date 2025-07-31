import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:intl/intl.dart';
import '../../blocs/auth/signup/signup_bloc.dart';
import '../../blocs/auth/signup/signup_event.dart';
import '../../blocs/auth/signup/signup_state.dart';
import '../../repositories/auth_repository.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const SignupScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: BlocProvider(
          create: (context) => SignupBloc(
            authRepository: RepositoryProvider.of<AuthRepository>(context),
          ),
          child: const SignupForm(),
        ),
      ),
    );
  }
}

class SignupForm extends StatelessWidget {
  const SignupForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SignupBloc, SignupState>(
      listener: (context, state) {
        if (state.status.isSuccess) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text('Account created successfully! Please login.'),
                backgroundColor: Theme.of(context).colorScheme.secondary,
              ),
            );
          Navigator.of(context).pop();
        } else if (state.status.isFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Sign Up Failure'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
        }
      },
      child: Align(
        alignment: const Alignment(0, -1 / 3),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.person_add,
                size: 80,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 16),
              Text(
                'Create Account',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 48),
              _FullNameInput(),
              const SizedBox(height: 16),
              _EmailInput(),
              const SizedBox(height: 16),
              _PasswordInput(),
              const SizedBox(height: 16),
              _DateOfBirthInput(),
              const SizedBox(height: 24),
              _SignUpButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class _FullNameInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignupBloc, SignupState>(
      buildWhen: (previous, current) => previous.fullName != current.fullName,
      builder: (context, state) {
        return TextField(
          key: const Key('signupForm_fullNameInput_textField'),
          onChanged: (fullName) => context.read<SignupBloc>().add(SignupFullNameChanged(fullName)),
          decoration: InputDecoration(
            labelText: 'Full Name',
            prefixIcon: const Icon(Icons.person),
            errorText: state.fullName.displayError != null ? 'Please enter a valid name' : null,
            border: const OutlineInputBorder(),
          ),
        );
      },
    );
  }
}

class _EmailInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignupBloc, SignupState>(
      buildWhen: (previous, current) => previous.email != current.email,
      builder: (context, state) {
        return TextField(
          key: const Key('signupForm_emailInput_textField'),
          onChanged: (email) => context.read<SignupBloc>().add(SignupEmailChanged(email)),
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Email',
            prefixIcon: const Icon(Icons.email),
            errorText: state.email.displayError != null ? 'Invalid email' : null,
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
    return BlocBuilder<SignupBloc, SignupState>(
      buildWhen: (previous, current) => previous.password != current.password,
      builder: (context, state) {
        return TextField(
          key: const Key('signupForm_passwordInput_textField'),
          onChanged: (password) => context.read<SignupBloc>().add(SignupPasswordChanged(password)),
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Password',
            prefixIcon: const Icon(Icons.lock),
            errorText: state.password.displayError != null ? 'Password must be at least 6 characters' : null,
            border: const OutlineInputBorder(),
          ),
        );
      },
    );
  }
}

class _DateOfBirthInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignupBloc, SignupState>(
      buildWhen: (previous, current) => previous.dateOfBirth != current.dateOfBirth,
      builder: (context, state) {
        return TextField(
          key: const Key('signupForm_dateOfBirthInput_textField'),
          readOnly: true,
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
              firstDate: DateTime(1950),
              lastDate: DateTime.now(),
            );
            if (date != null) {
              context.read<SignupBloc>().add(SignupDateOfBirthChanged(date));
            }
          },
          controller: TextEditingController(
            text: state.dateOfBirth != null
                ? DateFormat('MMM dd, yyyy').format(state.dateOfBirth!)
                : '',
          ),
          decoration: const InputDecoration(
            labelText: 'Date of Birth',
            prefixIcon: Icon(Icons.calendar_today),
            border: OutlineInputBorder(),
          ),
        );
      },
    );
  }
}

class _SignUpButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignupBloc, SignupState>(
      builder: (context, state) {
        return state.status.isInProgress
            ? const CircularProgressIndicator()
            : SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  key: const Key('signupForm_continue_raisedButton'),
                  onPressed: state.isValid
                      ? () => context.read<SignupBloc>().add(SignupSubmitted())
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('SIGN UP'),
                ),
              );
      },
    );
  }
}