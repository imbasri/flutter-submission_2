import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/restaurant_provider.dart';
import '../../provider/theme_provider.dart';
import '../../utils/result_state.dart';
import '../widget/loading_indicator.dart';
import '../widget/error_message.dart';
import '../widget/restaurant_card.dart';
import 'detail_page.dart';
import 'search_page.dart';
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RestaurantProvider>(context, listen: false).fetchRestaurants();
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant App'),
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                icon: Icon(
                  themeProvider.isDarkMode 
                    ? Icons.light_mode 
                    : Icons.dark_mode,
                ),
                onPressed: () {
                  themeProvider.toggleTheme();
                },
                tooltip: themeProvider.isDarkMode 
                  ? 'Switch to Light Mode' 
                  : 'Switch to Dark Mode',
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SearchPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<RestaurantProvider>(
        builder: (context, provider, child) {
          switch (provider.result.state) {
            case ResultState.loading:
              return const LoadingIndicator(message: 'Loading restaurants...');
            case ResultState.hasData:
              return LayoutBuilder(
                builder: (context, constraints) {
                  final isWeb = constraints.maxWidth > 800;
                  final crossAxisCount = isWeb ? 
                    (constraints.maxWidth > 1200 ? 3 : 2) : 1;
                  final maxWidth = isWeb ? 1200.0 : double.infinity;
                  
                  if (isWeb && crossAxisCount > 1) {
                    return RefreshIndicator(
                      onRefresh: () => provider.fetchRestaurants(),
                      child: Center(
                        child: Container(
                          constraints: BoxConstraints(maxWidth: maxWidth),
                          child: CustomScrollView(
                            slivers: [
                              SliverPadding(
                                padding: const EdgeInsets.all(16),
                                sliver: SliverGrid(
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    childAspectRatio: isWeb ? 1.2 : 1.4,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                  ),
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                      final restaurant = provider.result.data![index];
                                      return RestaurantCard(
                                        restaurant: restaurant,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => DetailPage(restaurantId: restaurant.id),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    childCount: provider.result.data!.length,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  } else {
                    return RefreshIndicator(
                      onRefresh: () => provider.fetchRestaurants(),
                      child: Center(
                        child: Container(
                          constraints: BoxConstraints(maxWidth: maxWidth),
                          child: ListView.builder(
                            padding: EdgeInsets.all(isWeb ? 16 : 8),
                            itemCount: provider.result.data!.length,
                            itemBuilder: (context, index) {
                              final restaurant = provider.result.data![index];
                              return Container(
                                margin: EdgeInsets.only(
                                  bottom: isWeb ? 16 : 8,
                                ),
                                child: RestaurantCard(
                                  restaurant: restaurant,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DetailPage(restaurantId: restaurant.id),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  }
                },
              );
            case ResultState.noData:
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.restaurant,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      provider.result.message,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => provider.fetchRestaurants(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            case ResultState.error:
              return ErrorMessage(
                message: provider.result.message,
                onRetry: () => provider.fetchRestaurants(),
              );
          }
        },
      ),
    );
  }
}
