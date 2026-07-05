import 'package:flutter/material.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/shared/widgets/corvus_top_bar.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _hasResults = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _submitSearch(String query) {
    if (query.isNotEmpty) {
      setState(() {
        _hasResults = true;
      });
      // Here you would trigger actual search API calls.
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: CorvusTopBar(
        showLogo: false,
        titleWidget: Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0),
          child: SizedBox(
            height: 44,
            child: TextField(
              controller: _searchController,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onSubmitted: _submitSearch,
              onChanged: (value) {
                if (_hasResults) {
                  setState(() {
                    _hasResults = false;
                  });
                } else {
                  setState(() {});
                }
              },
              decoration: InputDecoration(
                hintText: l10n.searchFieldLabelHint,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                prefixIcon: Icon(Icons.search, color: colorScheme.onSurfaceVariant),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _hasResults = false;
                          });
                        },
                      )
                    : Icon(Icons.mic_none, color: colorScheme.onSurfaceVariant),
                filled: true,
                fillColor: colorScheme.primary.withValues(alpha: 0.08),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _hasResults
                ? Center(
                    child: Text(
                      l10n.searchPlaceholderResult(_searchController.text),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : _searchController.text.isEmpty
                    ? Center(
                        child: Text(
                          l10n.searchEmptyState,
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      )
                    : ListTile(
                        leading: const Icon(Icons.search),
                        title: Text(l10n.searchSuggestion(_searchController.text)),
                        onTap: () {
                          _submitSearch(_searchController.text);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
