import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/features/auth/presentation/provider/auth_provider.dart';

class CorvusTopBar extends StatelessWidget implements PreferredSizeWidget {
  const CorvusTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final photoUrl = context.select<AuthProvider, String?>((a) => a.currentUser?.photoUrl);
    final role = context.select<AuthProvider, String?>((a) => a.role);
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ColorFilter.mode(
            Theme.of(context).colorScheme.surface,
            BlendMode.srcIn,
          ),
          child: Container(color: Colors.transparent),
        ),
      ),
      actions: [
        if (photoUrl != null && photoUrl.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                if (role == 'PROFESOR') {
                  if (GoRouterState.of(context).matchedLocation != '/prof-profile') {
                    context.push('/prof-profile');
                  }
                } else {
                  if (GoRouterState.of(context).matchedLocation != '/profile') {
                    context.push('/profile');
                  }
                }
              },
              child: CircleAvatar(
                backgroundImage: NetworkImage(photoUrl),
                radius: 18,
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                if (role == 'PROFESOR') {
                  if (GoRouterState.of(context).matchedLocation != '/prof-profile') {
                    context.push('/prof-profile');
                  }
                } else {
                  if (GoRouterState.of(context).matchedLocation != '/profile') {
                    context.push('/profile');
                  }
                }
              },
              child: const CircleAvatar(
                child: Icon(Icons.person),
                radius: 18,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
