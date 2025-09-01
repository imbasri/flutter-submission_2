import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/detail_provider.dart';
import '../../provider/review_provider.dart';
import '../../static/constant_data.dart';
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
              top:
                  MediaQuery.of(context).padding.top + 8, // Area aman + padding
              left: isWeb ? 24 : 16,
              right: isWeb ? 24 : 16,
              bottom: 16,
            ),
            decoration: BoxDecoration(
              color: Colors.green,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
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
                ApiSuccess() => _buildDetailContent(context, provider, isWeb),
                ApiEmpty() => const Center(child: Text('No data')),
              };
            },
          );
        },
      ),
      floatingActionButton: LayoutBuilder(
        builder: (context, constraints) {
          final isWeb = constraints.maxWidth > 800;
          if (!isWeb) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            onPressed: () => Navigator.pop(context),
            tooltip: 'Back to Home',
            icon: const Icon(Icons.home),
            label: const Text('Home'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildDetailContent(
    BuildContext context,
    DetailProvider provider,
    bool isWeb,
  ) {
    final restaurant = provider.result.dataOrNull!;
    return NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          SliverAppBar(
            expandedHeight: isWeb ? 250.0 : 200.0,
            floating: true, // AppBar akan muncul saat scroll ke atas
            snap: true, // AppBar akan snap in/out dengan animasi
            pinned: false, // AppBar tidak akan tetap terpin di atas
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: isWeb
                ? [
                    Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 16.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              'Home',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            color: Colors.white70,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Restaurant Details',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 16),
                        ],
                      ),
                    ),
                  ]
                : null,
            flexibleSpace: FlexibleSpaceBar(
              title: Container(
                constraints: BoxConstraints(maxWidth: isWeb ? 600 : 250),
                child: Text(
                  restaurant.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: isWeb ? 20 : 16,
                    shadows: const [
                      Shadow(
                        offset: Offset(1.0, 1.0),
                        blurRadius: 3.0,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    ],
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: isWeb ? 2 : 1,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'restaurant-image-${restaurant.id}',
                    child: Image.network(
                      ConstantData.getLargeImageUrl(restaurant.pictureId),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.error,
                            size: 50,
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
                ],
              ),
            ),
          ),
        ];
      },
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Center(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: isWeb ? 1000 : double.infinity,
                ),
                padding: EdgeInsets.all(isWeb ? 32.0 : 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: Colors.red,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${restaurant.address}, ${restaurant.city}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.star, color: Colors.amber),
                                const SizedBox(width: 8),
                                Text(
                                  restaurant.rating.toString(),
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'About',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              restaurant.description,
                              textAlign: TextAlign.justify,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Menu',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Foods',
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: restaurant.menus.foods.map((food) {
                                  return Chip(
                                    label: Text(food.name),
                                    backgroundColor: Theme.of(
                                      context,
                                    ).colorScheme.primaryContainer,
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Drinks',
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: restaurant.menus.drinks.map((drink) {
                                  return Chip(
                                    label: Text(drink.name),
                                    backgroundColor: Theme.of(
                                      context,
                                    ).colorScheme.secondaryContainer,
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Customer Reviews (${restaurant.customerReviews.length})',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ReviewForm(
                                          restaurantId: widget.restaurantId,
                                          restaurantName: restaurant.name,
                                        ),
                                      ),
                                    );
                                    if (result == true && mounted) {
                                      _showTopSnackBar(context, isWeb);
                                      final reviewProvider = context
                                          .read<ReviewProvider>();
                                      final detailProvider = context
                                          .read<DetailProvider>();
                                      if (reviewProvider.result.isSuccess) {
                                        detailProvider.updateReviewsLocally(
                                          reviewProvider.result.dataOrNull!,
                                        );
                                      }
                                      detailProvider.forceRefreshWithDelay(
                                        widget.restaurantId,
                                      );
                                    }
                                  },
                                  icon: const Icon(Icons.add),
                                  label: const Text('Add Review'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ReviewList(reviews: restaurant.customerReviews),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
