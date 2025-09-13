import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/favorites_provider.dart';
import '../../provider/theme_provider.dart';
import '../widget/loading_indicator.dart';
import '../widget/error_message.dart';
import '../widget/restaurant_card.dart';
import 'detail_page.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FavoritesProvider>(
        context,
        listen: false,
      ).loadFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restoran Favorit'),
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
        ],
      ),
      body: Consumer<FavoritesProvider>(
        builder: (context, favoritesProvider, child) {
          switch (favoritesProvider.state) {
            case FavoritesState.loading:
              return const LoadingIndicator();
            case FavoritesState.error:
              return ErrorMessage(
                message: favoritesProvider.message,
                onRetry: () => favoritesProvider.loadFavorites(),
              );
            case FavoritesState.loaded:
              if (favoritesProvider.favorites.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite_border,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Belum Ada Restoran Favorit',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Tambahkan restoran ke favorit untuk melihatnya di sini',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => favoritesProvider.loadFavorites(),
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: favoritesProvider.favorites.length,
                  itemBuilder: (context, index) {
                    final restaurant = favoritesProvider.favorites[index];
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
                        ).then((_) {
                          favoritesProvider.loadFavorites();
                        });
                      },
                    );
                  },
                ),
              );
          }
        },
      ),
    );
  }
}
