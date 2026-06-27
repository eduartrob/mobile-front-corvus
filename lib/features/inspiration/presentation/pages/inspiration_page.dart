import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:mobile/l10n/app_localizations.dart';

import 'package:mobile/features/inspiration/presentation/provider/inspiration_provider.dart';
import 'package:mobile/features/inspiration/presentation/widgets/glass_container.dart';
import 'package:mobile/core/widgets/corvus_top_bar.dart';
import 'package:mobile/features/inspiration/presentation/widgets/project_card.dart';
import 'package:mobile/features/inspiration/presentation/widgets/floating_ai_input.dart';

class InspirationPage extends StatefulWidget {
  const InspirationPage({super.key});

  @override
  State<InspirationPage> createState() => _InspirationPageState();
}

class _InspirationPageState extends State<InspirationPage> {
  late final ScrollController _scrollController;
  bool _isFloatingInputVisible = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
      if (_isFloatingInputVisible) {
        setState(() {
          _isFloatingInputVisible = false;
        });
      }
    } else if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
      if (!_isFloatingInputVisible) {
        setState(() {
          _isFloatingInputVisible = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final provider = context.watch<InspirationProvider>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const CorvusTopBar(),
      body: Stack(
        children: [
          // Background Base (Deep dark blue)
          Container(
            color: colorScheme.surface,
          ),
          
          // Main Scroll View
          SafeArea(
            bottom: false,
            child: RefreshIndicator(
              onRefresh: () => provider.loadProjects(),
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: 16),
                      
                      // Welcome Card (Only shown if showWelcome is true)
                      if (provider.showWelcome)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 24.0),
                          child: GlassContainer(
                            blur: 0, // Disable blur to avoid lag
                            opacity: 0.5,
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.insights,
                                      color: colorScheme.secondary,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      l10n.welcomeToCorvus,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  l10n.welcomeCorvusDesc,
                                  style: TextStyle(
                                    color: colorScheme.onSurfaceVariant,
                                    fontSize: 16,
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {
                                      provider.dismissWelcome();
                                    },
                                    child: const Text('Entendido'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      
                      // Section Header
                      Text(
                        l10n.unexploredProjects,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.unexploredProjectsDesc,
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ]),
                  ),
                ),
                
                // Projects List
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  sliver: provider.isLoading
                      ? const SliverToBoxAdapter(
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              return ProjectCard(project: provider.projects[index]);
                            },
                            childCount: provider.projects.length,
                          ),
                        ),
                ),
                
                // Bottom Padding for the floating input and bottom nav bar
                const SliverToBoxAdapter(
                  child: SizedBox(height: 160),
                ),
              ],
            ),
          ),

          // Floating AI Input
          Positioned(
            bottom: 0, // Reducido al mínimo, el margen interno de la tarjeta se encarga del espacio
            left: 0,
            right: 0,
            child: FloatingAiInput(isVisible: _isFloatingInputVisible),
          ),
        ],
      ),
    );
  }
}
