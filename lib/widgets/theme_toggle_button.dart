import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../theme/theme_cubit.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        return PopupMenuButton<ThemeType>(
          icon: Icon(
            _getThemeIcon(state.themeType, state.brightness),
            color: Theme.of(context).colorScheme.onSurface,
          ),
          tooltip: 'Change theme',
          onSelected: (ThemeType themeType) {
            context.read<ThemeCubit>().setTheme(themeType);
          },
          itemBuilder: (BuildContext context) => [
            PopupMenuItem<ThemeType>(
              value: ThemeType.light,
              child: Row(
                children: [
                  Icon(
                    Icons.light_mode,
                    color: state.themeType == ThemeType.light
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Light',
                    style: TextStyle(
                      color: state.themeType == ThemeType.light
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface,
                      fontWeight: state.themeType == ThemeType.light
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuItem<ThemeType>(
              value: ThemeType.dark,
              child: Row(
                children: [
                  Icon(
                    Icons.dark_mode,
                    color: state.themeType == ThemeType.dark
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Dark',
                    style: TextStyle(
                      color: state.themeType == ThemeType.dark
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface,
                      fontWeight: state.themeType == ThemeType.dark
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuItem<ThemeType>(
              value: ThemeType.system,
              child: Row(
                children: [
                  Icon(
                    Icons.settings_suggest,
                    color: state.themeType == ThemeType.system
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'System',
                    style: TextStyle(
                      color: state.themeType == ThemeType.system
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface,
                      fontWeight: state.themeType == ThemeType.system
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  IconData _getThemeIcon(ThemeType themeType, Brightness currentBrightness) {
    switch (themeType) {
      case ThemeType.light:
        return Icons.light_mode;
      case ThemeType.dark:
        return Icons.dark_mode;
      case ThemeType.system:
        return currentBrightness == Brightness.light
            ? Icons.light_mode
            : Icons.dark_mode;
    }
  }
}

class ThemeToggleChip extends StatelessWidget {
  const ThemeToggleChip({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildThemeOption(
                context,
                state,
                ThemeType.light,
                Icons.light_mode,
                'Light',
              ),
              _buildThemeOption(
                context,
                state,
                ThemeType.dark,
                Icons.dark_mode,
                'Dark',
              ),
              _buildThemeOption(
                context,
                state,
                ThemeType.system,
                Icons.settings_suggest,
                'Auto',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    ThemeState state,
    ThemeType themeType,
    IconData icon,
    String label,
  ) {
    final isSelected = state.themeType == themeType;
    
    return GestureDetector(
      onTap: () => context.read<ThemeCubit>().setTheme(themeType),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}