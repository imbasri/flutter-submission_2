import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/restaurant_provider.dart';
import '../../provider/theme_provider.dart';
import '../../utils/api_result.dart';
import '../widget/loading_indicator.dart';
import '../widget/error_message.dart';
import '../widget/restaurant_card.dart';
import 'detail_page.dart';
import 'search_page.dart';
import 'favorites_page.dart';
import 'settings_page.dart';

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
      Provider.of<RestaurantProvider>(
        context,
        listen: false,
      ).fetchRestaurants();
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
                  themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
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
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FavoritesPage()),
              );
            },
            tooltip: 'Restoran Favorit',
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchPage()),
              );
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: Consumer<RestaurantProvider>(
        builder: (context, provider, child) {
          return switch (provider.result) {
            ApiLoading() => const LoadingIndicator(
              message: 'Loading restaurants...',
            ),
            ApiSuccess(:final data) => LayoutBuilder(
              builder: (context, constraints) {
                final isWeb = constraints.maxWidth > 800;
                final crossAxisCount = isWeb
                    ? (constraints.maxWidth > 1200 ? 3 : 2)
                    : 1;
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
                                      builder: (context) => DetailPage(
                                        restaurantId: restaurant.id,
                                      ),
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
            ),
            ApiEmpty(:final message) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.restaurant, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    message,
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
            ),
            ApiFailure(:final message) => ErrorMessage(
              message: message,
              onRetry: () => provider.fetchRestaurants(),
            ),
          };
        },
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Drawer Header
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return DrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withValues(alpha: 0.8),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.restaurant,
                        size: 30,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Restaurant App',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'OrangeJuice',
                      ),
                    ),
                    Text(
                      'Tema: ${themeProvider.currentThemeName}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          
          // Menu Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text('Beranda'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.search),
                  title: const Text('Cari Restoran'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SearchPage()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.favorite),
                  title: const Text('Restoran Favorit'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const FavoritesPage()),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Pengaturan'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SettingsPage()),
                    );
                  },
                ),
                Consumer<ThemeProvider>(
                  builder: (context, themeProvider, child) {
                    return ListTile(
                      leading: Icon(
                        themeProvider.isDarkMode 
                            ? Icons.light_mode 
                            : Icons.dark_mode,
                      ),
                      title: Text(
                        themeProvider.isDarkMode 
                            ? 'Beralih ke Tema Terang' 
                            : 'Beralih ke Tema Gelap',
                      ),
                      onTap: () {
                        themeProvider.toggleTheme();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Tema berubah ke ${themeProvider.isDarkMode ? "Gelap" : "Terang"}',
                            ),
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          
          // Footer
          Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Restaurant App v1.0',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
