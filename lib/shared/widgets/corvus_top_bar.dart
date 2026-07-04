import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/features/auth/presentation/provider/auth_provider.dart';

class CorvusTopBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showLogo;
  final Widget? titleWidget;

  const CorvusTopBar({
    super.key,
    this.showLogo = true,
    this.titleWidget,
  });

  @override
  Widget build(BuildContext context) {
    final photoUrl = context.select<AuthProvider, String?>((a) => a.currentUser?.photoUrl);
    final role = context.select<AuthProvider, String?>((a) => a.role);
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.surface,
      scrolledUnderElevation: 0,
      titleSpacing: showLogo && titleWidget == null ? 16.0 : 0.0,
      title: titleWidget ?? (showLogo 
          ? SvgPicture.asset(
              'assets/icons/logo.svg',
              height: 32,
              width: 32,
              colorFilter: ColorFilter.mode(
                Theme.of(context).colorScheme.primary,
                BlendMode.srcIn,
              ),
            ) 
          : null),
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
                radius: 18,
                child: Icon(Icons.person),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
