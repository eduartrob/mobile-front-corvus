/*  */import 'package:flutter/material.dart';

Future<void> showUserProfileModal({
  required BuildContext context,
  required String name,
  required String avatarUrl,
  required String bio,
  required List<String> tags,
  required Widget actionButton,
}) {
  return showModalBottomSheet(
    context: context,
    useRootNavigator: true, // This makes the modal cover the bottom navigation bar
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _UserProfileModal(
      name: name,
      avatarUrl: avatarUrl,
      bio: bio,
      tags: tags,
      actionButton: actionButton,
    ),
  );
}

class _UserProfileModal extends StatelessWidget {
  final String name;
  final String avatarUrl;
  final String bio;
  final List<String> tags;
  final Widget actionButton;

  const _UserProfileModal({
    required this.name,
    required this.avatarUrl,
    required this.bio,
    required this.tags,
    required this.actionButton,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    // Mountain illustration from Unsplash (colorful vector-like style)
    const coverPhotoUrl = 'https://images.unsplash.com/photo-1549880338-65ddcdfd017b?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&q=80';

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Cover Photo and Avatar Header
            SizedBox(
              height: 150 + 50, // Cover height + space for overlapping avatar/text
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Cover Photo
                  Container(
                    height: 150,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      image: DecorationImage(
                        image: NetworkImage(coverPhotoUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Profile Avatar
                  Positioned(
                    left: 16,
                    top: 150 - 45, // Half inside, half outside
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colorScheme.surface,
                          width: 4,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 45,
                        backgroundColor: colorScheme.primaryContainer,
                        backgroundImage: (avatarUrl.isNotEmpty) 
                            ? NetworkImage(avatarUrl) 
                            : null,
                        child: (avatarUrl.isEmpty)
                            ? Text(
                                name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?',
                                style: TextStyle(
                                  color: colorScheme.onPrimaryContainer,
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                    ),
                  ),
                  // Name and Mocked Description next to Avatar
                  Positioned(
                    left: 16 + 90 + 16, // padding + avatar width + padding
                    right: 16,
                    top: 150 + 8, // Just below the cover photo line
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Alumno',
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Close Button
                  Positioned(
                    top: 12,
                    right: 12,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(6), // Controls the size of the background circle
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.4),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close, 
                          color: Colors.white,
                          size: 18, // Smaller icon size
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (bio.isNotEmpty) ...[
                      Text(
                        bio,
                        style: TextStyle(
                          fontSize: 15,
                          color: colorScheme.onSurface,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    
                    if (tags.isNotEmpty) ...[
                      Text(
                        'Habilidades',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 6,
                        runSpacing: -4, // Reduced spacing between lines of chips
                        children: tags.map((tag) {
                          return Chip(
                            label: Text(tag),
                            backgroundColor: colorScheme.primaryContainer.withValues(alpha: 0.5),
                            labelStyle: TextStyle(
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w500,
                            ),
                            side: BorderSide.none,
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ],
                ),
              ),
            ),
            
            // Action Button pinned to bottom
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                  ),
                ),
              ),
              child: actionButton,
            ),
          ],
        ),
      ),
    );
  }
}
