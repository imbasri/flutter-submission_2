import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/search_provider.dart';
import '../../utils/api_result.dart';
import '../widget/loading_indicator.dart';
import '../widget/error_message.dart';
import '../widget/restaurant_card.dart';
import 'detail_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SearchProvider>(context, listen: false).clearSearch();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Restaurant'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search restaurant...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    Provider.of<SearchProvider>(
                      context,
                      listen: false,
                    ).clearSearch();
                  },
                ),
              ),
              onChanged: (query) {
                if (query.isNotEmpty) {
                  Provider.of<SearchProvider>(
                    context,
                    listen: false,
                  ).searchRestaurants(query);
                } else {
                  Provider.of<SearchProvider>(
                    context,
                    listen: false,
                  ).clearSearch();
                }
              },
              textInputAction: TextInputAction.search,
              onSubmitted: (query) {
                if (query.isNotEmpty) {
                  Provider.of<SearchProvider>(
                    context,
                    listen: false,
                  ).searchRestaurants(query);
                }
              },
            ),
          ),
        ),
      ),
      body: Consumer<SearchProvider>(
        builder: (context, provider, child) {
          return switch (provider.result) {
            ApiLoading() => const LoadingIndicator(
              message: 'Searching restaurants...',
            ),
            ApiSuccess(:final data) => LayoutBuilder(
              builder: (context, constraints) {
                final isWeb = constraints.maxWidth > 800;
                final crossAxisCount = isWeb
                    ? (constraints.maxWidth > 1200 ? 3 : 2)
                    : 1;
                final maxWidth = isWeb ? 1200.0 : double.infinity;

                if (isWeb && crossAxisCount > 1) {
                  return Center(
                    child: Container(
                      constraints: BoxConstraints(maxWidth: maxWidth),
                      child: CustomScrollView(
                        slivers: [
                          SliverPadding(
                            padding: const EdgeInsets.all(16),
                            sliver: SliverGrid(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    childAspectRatio: isWeb ? 1.2 : 1.4,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                  ),
                              delegate: SliverChildBuilderDelegate((
                                context,
                                index,
                              ) {
                                final restaurant = data[index];
                                return RestaurantCard(
                                  restaurant: restaurant,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DetailPage(
                                          restaurantId: restaurant.id,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }, childCount: data.length),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  return Center(
                    child: Container(
                      constraints: BoxConstraints(maxWidth: maxWidth),
                      child: ListView.builder(
                        padding: EdgeInsets.all(isWeb ? 16 : 8),
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          final restaurant = data[index];
                          return Container(
                            margin: EdgeInsets.only(bottom: isWeb ? 16 : 8),
                            child: RestaurantCard(
                              restaurant: restaurant,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        DetailPage(restaurantId: restaurant.id),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  );
                }
              },
            ),
            ApiEmpty(:final message) => Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _searchController.text.isEmpty
                          ? Icons.search
                          : Icons.restaurant_menu,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      message.isNotEmpty
                          ? message
                          : (_searchController.text.isEmpty
                                ? 'Search for your favorite restaurants'
                                : 'No restaurants found'),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (_searchController.text.isEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Try searching for "cafe", "pizza", or other keywords',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[500],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            ApiFailure(:final message) => ErrorMessage(
              message: message,
              onRetry: () {
                if (provider.query.isNotEmpty) {
                  provider.searchRestaurants(provider.query);
                }
              },
            ),
          };
        },
      ),
    );
  }
}
