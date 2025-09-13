import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/detail_provider.dart';
import '../../provider/favorites_provider.dart';
import '../../utils/api_result.dart';
import '../widget/review_list.dart';
import 'review_form.dart';

class DetailPage extends StatefulWidget {
  final String restaurantId;
  const DetailPage({super.key, required this.restaurantId});
  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  OverlayEntry? _overlayEntry;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DetailProvider>().fetchRestaurantDetail(widget.restaurantId);
    });
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  Color _getRatingColor(double rating) {
    if (rating >= 4.5) return Colors.green;
    if (rating >= 4.0) return Colors.lightGreen;
    if (rating >= 3.5) return Colors.orange;
    if (rating >= 3.0) return Colors.deepOrange;
    return Colors.red;
  }
  String _getRatingText(double rating) {
    if (rating >= 4.5) return 'Excellent';
    if (rating >= 4.0) return 'Very Good';
    if (rating >= 3.5) return 'Good';
    if (rating >= 3.0) return 'Fair';
    return 'Poor';
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showTopSnackBar(BuildContext context, bool isWeb) {
    _removeOverlay();
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 8,
              left: isWeb ? 24 : 16,
              right: isWeb ? 24 : 16,
              bottom: 16,
            ),
            decoration: const BoxDecoration(
              color: Colors.green,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Review berhasil ditambahkan!',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _removeOverlay,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
    Future.delayed(const Duration(seconds: 5), () {
      _removeOverlay();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWeb = constraints.maxWidth > 800;
          return Consumer<DetailProvider>(
            builder: (context, provider, child) {
              return switch (provider.result) {
                ApiLoading() => const Center(
                  child: CircularProgressIndicator(),
                ),
                ApiFailure(:final message) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 80, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(message),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () =>
                            provider.fetchRestaurantDetail(widget.restaurantId),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
                ApiSuccess(:final data) => _buildDetailContent(context, provider, isWeb, data),
                ApiEmpty() => const Center(child: Text('No data')),
              };
            },
          );
        },
      ),
      floatingActionButton: Consumer2<FavoritesProvider, DetailProvider>(
        builder: (context, favoritesProvider, detailProvider, child) {
          // Initialize favorite status when widget builds
          WidgetsBinding.instance.addPostFrameCallback((_) {
            favoritesProvider.checkFavoriteStatus(widget.restaurantId);
          });
          
          final isFavorite = favoritesProvider.isFavoriteSync(widget.restaurantId);
          
          return FloatingActionButton(
            onPressed: () async {
              if (detailProvider.result case ApiSuccess(:final data)) {
                final restaurant = data.toRestaurant();
                await favoritesProvider.toggleFavorite(restaurant);
                
                // Show snackbar with better styling
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(
                            isFavorite ? Icons.heart_broken : Icons.favorite,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            isFavorite 
                                ? 'Dihapus dari favorit' 
                                : 'Ditambahkan ke favorit',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: isFavorite ? Colors.grey[700] : Colors.red,
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                }
              }
            },
            backgroundColor: isFavorite ? Colors.red : Colors.grey[300],
            foregroundColor: isFavorite ? Colors.white : Colors.grey[600],
            tooltip: isFavorite ? 'Hapus dari favorit' : 'Tambah ke favorit',
            child: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              size: 28,
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildDetailContent(BuildContext context, DetailProvider provider, bool isWeb, data) {
    final restaurant = data;
    
    return NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          SliverAppBar(
            expandedHeight: isWeb ? 250.0 : 200.0,
            floating: true,
            snap: true,
            pinned: false,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fitur share akan segera hadir'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                tooltip: 'Bagikan',
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'restaurant-image-${restaurant.id}',
                    child: Image.network(
                      restaurant.pictureUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.restaurant,
                            size: 64,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black26,
                          Colors.black54,
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          restaurant.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                offset: Offset(0, 1),
                                blurRadius: 3,
                                color: Colors.black54,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.white, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '${restaurant.city}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    offset: Offset(0, 1),
                                    blurRadius: 3,
                                    color: Colors.black54,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ];
      },
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isWeb ? 32.0 : 16.0),
        child: Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: isWeb ? 1000 : double.infinity,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Restaurant Info Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Rating
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.amber.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${restaurant.rating}/5.0',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getRatingColor(restaurant.rating),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _getRatingText(restaurant.rating),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Address
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.location_on,
                                color: Colors.red,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '${restaurant.address}, ${restaurant.city}',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Description Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.description,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Deskripsi',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          restaurant.description,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            height: 1.6,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Categories
                if (restaurant.categories.isNotEmpty) ...[
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.category,
                                color: Theme.of(context).primaryColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Kategori',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              ...restaurant.categories.map((category) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Text(
                                    category.name,
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Menu Section
                _buildMenuSection(restaurant),
                
                const SizedBox(height: 16),
                
                // Reviews Section
                _buildReviewSection(context, restaurant, isWeb),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuSection(restaurant) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.restaurant_menu,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Menu',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Foods
            if (restaurant.menus.foods.isNotEmpty) ...[
              Text(
                'Makanan',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.orange[700],
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...restaurant.menus.foods.map((food) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.orange.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        food.name,
                        style: TextStyle(
                          color: Colors.orange[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 16),
            ],
            
            // Drinks
            if (restaurant.menus.drinks.isNotEmpty) ...[
              Text(
                'Minuman',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[700],
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...restaurant.menus.drinks.map((drink) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.blue.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        drink.name,
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReviewSection(BuildContext context, restaurant, bool isWeb) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.rate_review,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Review',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReviewForm(
                          restaurantId: restaurant.id,
                          restaurantName: restaurant.name,
                        ),
                      ),
                    ).then((_) {
                      // Refresh detail when coming back from review form
                      context.read<DetailProvider>().fetchRestaurantDetail(restaurant.id);
                      _showTopSnackBar(context, isWeb);
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah Review'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ReviewList(reviews: restaurant.customerReviews),
          ],
        ),
      ),
    );
  }
}
