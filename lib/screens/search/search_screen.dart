import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../providers/search_provider.dart';
import 'widgets/search_result_tile.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SearchProvider()..loadRecipes(),
      child: const _SearchBody(),
    );
  }
}

class _SearchBody extends StatefulWidget {
  const _SearchBody();

  @override
  State<_SearchBody> createState() => _SearchBodyState();
}

class _SearchBodyState extends State<_SearchBody> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final searchProvider = context.watch<SearchProvider>();

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: l10n.searchHint,
            border: InputBorder.none,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _controller.clear();
                      setState(() {});
                      searchProvider.search('');
                    },
                  )
                : null,
          ),
          onChanged: (value) {
            setState(() {});
            searchProvider.search(value);
          },
        ),
      ),
      body: searchProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : searchProvider.results.isEmpty && searchProvider.query.isNotEmpty
              ? const Center(child: Text('No results found'))
              : ListView.builder(
                  itemCount: searchProvider.results.length,
                  itemBuilder: (context, index) {
                    return SearchResultTile(
                      recipe: searchProvider.results[index],
                    );
                  },
                ),
    );
  }
}
