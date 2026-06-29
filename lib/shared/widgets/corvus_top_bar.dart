import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/features/auth/presentation/provider/auth_provider.dart';
import 'package:mobile/l10n/app_localizations.dart';

class CorvusTopBar extends StatelessWidget implements PreferredSizeWidget {
  const CorvusTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final photoUrl = context.select<AuthProvider, String?>((a) => a.currentUser?.photoUrl);
    final role = context.select<AuthProvider, String?>((a) => a.role);
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer.withOpacity(0.7),
      elevation: 0,
      scrolledUnderElevation: 0,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ColorFilter.mode(
            Theme.of(context).colorScheme.surfaceContainer.withOpacity(0.7),
            BlendMode.srcIn,
          ),
          child: Container(color: Colors.transparent),
        ),
      ),
      title: Row(
        children: [
          SvgPicture.asset(
            'assets/icons/logo.svg',
            height: 32,
            width: 32,
            colorFilter: ColorFilter.mode(
              Theme.of(context).colorScheme.primary,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Corvus',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
              fontSize: 24,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {
            showSearch(
              context: context,
              delegate: CorvusSearchDelegate(l10n: AppLocalizations.of(context)!),
            );
          },
          icon: const Icon(Icons.search),
        ),
        if (photoUrl != null && photoUrl.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                if (role == 'PROFESOR') {
                  if (GoRouterState.of(context).matchedLocation != '/prof-profile') {
                    context.push('/prof-profile');
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

class CorvusSearchDelegate extends SearchDelegate<String> {
  final AppLocalizations l10n;

  CorvusSearchDelegate({required this.l10n});

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: theme.colorScheme.surfaceContainerHigh,
        elevation: 0,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
      ),
    );
  }

  @override
  String get searchFieldLabel => l10n.searchFieldLabelHint;

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Center(
      child: Text(
        l10n.searchPlaceholderResult(query),
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return Center(
        child: Text(
          l10n.searchEmptyState,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return ListTile(
      leading: const Icon(Icons.search),
      title: Text(l10n.searchSuggestion(query)),
      onTap: () {
        showResults(context);
      },
    );
  }
}
