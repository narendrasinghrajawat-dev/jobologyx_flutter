import 'package:flutter/material.dart';

/// Circular avatar for a company logo or user profile image. Falls back to
/// [fallbackText]'s first letter (or a generic icon when that's empty) on a
/// missing URL, broken image, or load failure — never crashes on bad data.
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    this.imageUrl,
    this.fallbackText,
    this.radius = 24,
    this.icon = Icons.business_rounded,
  });

  final String? imageUrl;
  final String? fallbackText;
  final double radius;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasImage = imageUrl != null && imageUrl!.trim().isNotEmpty;

    return CircleAvatar(
      radius: radius,
      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
      backgroundImage: hasImage ? NetworkImage(imageUrl!) : null,
      onBackgroundImageError: hasImage ? (_, _) {} : null,
      child: hasImage
          ? null
          : (fallbackText != null && fallbackText!.trim().isNotEmpty)
              ? Text(
                  fallbackText!.trim()[0].toUpperCase(),
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: radius * 0.7,
                  ),
                )
              : Icon(icon, color: theme.colorScheme.primary, size: radius),
    );
  }
}
