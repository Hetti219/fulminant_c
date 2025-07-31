import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'theme_cubit.dart';
import '../widgets/theme_toggle_button.dart';

class ThemeTestPage extends StatelessWidget {
  const ThemeTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Test'),
        actions: const [ThemeToggleButton()],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Theme Test Page',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 16),
            
            // Color Scheme Demo
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Color Scheme',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _ColorChip(
                          label: 'Primary',
                          color: Theme.of(context).colorScheme.primary,
                          textColor: Theme.of(context).colorScheme.onPrimary,
                        ),
                        _ColorChip(
                          label: 'Secondary',
                          color: Theme.of(context).colorScheme.secondary,
                          textColor: Theme.of(context).colorScheme.onSecondary,
                        ),
                        _ColorChip(
                          label: 'Tertiary',
                          color: Theme.of(context).colorScheme.tertiary,
                          textColor: Theme.of(context).colorScheme.onTertiary,
                        ),
                        _ColorChip(
                          label: 'Surface',
                          color: Theme.of(context).colorScheme.surface,
                          textColor: Theme.of(context).colorScheme.onSurface,
                        ),
                        _ColorChip(
                          label: 'Error',
                          color: Theme.of(context).colorScheme.error,
                          textColor: Theme.of(context).colorScheme.onError,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Button Demo
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Buttons',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ElevatedButton(
                          onPressed: () {},
                          child: const Text('Elevated Button'),
                        ),
                        OutlinedButton(
                          onPressed: () {},
                          child: const Text('Outlined Button'),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text('Text Button'),
                        ),
                        FloatingActionButton(
                          onPressed: () {},
                          mini: true,
                          child: const Icon(Icons.add),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Input Demo
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Input Fields',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'Enter your email',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter your password',
                        suffixIcon: Icon(Icons.visibility),
                      ),
                      obscureText: true,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Theme Toggle Demo
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Theme Controls',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    const ThemeToggleChip(),
                    const SizedBox(height: 16),
                    BlocBuilder<ThemeCubit, ThemeState>(
                      builder: (context, state) {
                        return Text(
                          'Current Theme: ${state.themeType.name.toUpperCase()}\n'
                          'Current Brightness: ${state.brightness.name.toUpperCase()}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        );
                      },
                    ),
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

class _ColorChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;

  const _ColorChip({
    required this.label,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}