import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../blocs/auth/biometric/biometric_bloc.dart';
import '../../repositories/biometric_service.dart';

class BiometricSettingsScreen extends StatelessWidget {
  const BiometricSettingsScreen({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
        builder: (_) => const BiometricSettingsScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Biometric Authentication'),
        centerTitle: true,
      ),
      body: BlocProvider(
        create: (context) => BiometricBloc(
          biometricService: RepositoryProvider.of<BiometricService>(context),
        )..add(BiometricStatusChecked()),
        child: const BiometricSettingsView(),
      ),
    );
  }
}

class BiometricSettingsView extends StatelessWidget {
  const BiometricSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<BiometricBloc, BiometricState>(
      listener: (context, state) {
        if (state is BiometricEnrollmentSuccess) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: const Text(
                    'Biometric authentication enabled successfully!'),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
            );
        }

        if (state is BiometricEnrollmentFailed) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
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
                          Icons.fingerprint,
                          color: Theme.of(context).colorScheme.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Two-Factor Authentication',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add an extra layer of security to your account',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 20),
                    _BiometricStatusCard(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _BiometricInfoCard(),
          ],
        ),
      ),
    );
  }
}

class _BiometricStatusCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BiometricBloc, BiometricState>(
      builder: (context, state) {
        if (state is BiometricLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is BiometricNotAvailable) {
          return _NotAvailableCard(reason: state.reason);
        }

        if (state is BiometricAvailable) {
          return _AvailableCard(
            isEnabled: state.isEnabled,
            biometricTypeName: state.biometricTypeName,
          );
        }

        return _ErrorCard();
      },
    );
  }
}

class _NotAvailableCard extends StatelessWidget {
  final String reason;

  const _NotAvailableCard({required this.reason});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning,
            color: Theme.of(context).colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Not Available',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  reason,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AvailableCard extends StatelessWidget {
  final bool isEnabled;
  final String biometricTypeName;

  const _AvailableCard({
    required this.isEnabled,
    required this.biometricTypeName,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Column(
      children: [
        Row(
          children: [
            Icon(
              isEnabled ? Icons.security : Icons.security_outlined,
              color: isEnabled
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$biometricTypeName Authentication',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Text(
                    isEnabled
                        ? 'Enabled - Required after password'
                        : 'Disabled - Only password required',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            BlocBuilder<BiometricBloc, BiometricState>(
              builder: (context, state) {
                final bool isLoading = state is BiometricLoading;

                return Switch(
                  value: isEnabled,
                  onChanged: isLoading
                      ? null
                      : (bool value) {
                          if (value && user != null) {
                            context.read<BiometricBloc>().add(
                                  BiometricEnabled(user.email!),
                                );
                          } else {
                            context
                                .read<BiometricBloc>()
                                .add(BiometricDisabled());
                          }
                        },
                );
              },
            ),
          ],
        ),
        if (isEnabled) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Two-factor authentication is active. You\'ll need both your password and $biometricTypeName to sign in.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _ErrorCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Error',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  'Unable to check biometric status',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () =>
                context.read<BiometricBloc>().add(BiometricStatusChecked()),
            child: Text(
              'Retry',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BiometricInfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.help_outline,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'How It Works',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _InfoItem(
              icon: Icons.password,
              text: 'Enter your email and password as usual',
            ),
            const SizedBox(height: 8),
            _InfoItem(
              icon: Icons.fingerprint,
              text: 'Verify your identity with biometric authentication',
            ),
            const SizedBox(height: 8),
            _InfoItem(
              icon: Icons.security,
              text: 'Access granted only after both steps succeed',
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'If biometric fails, you can use your device PIN or pattern as backup',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
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
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
