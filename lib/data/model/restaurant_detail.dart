import 'review.dart';
import '../../static/constant_data.dart';

class RestaurantDetail {
  final String id;
  final String name;
  final String description;
  final String city;
  final String address;
  final String pictureId;
  final List<Category> categories;
  final Menus menus;
  final double rating;
  final List<CustomerReview> customerReviews;

  RestaurantDetail({
    required this.id,
    required this.name,
    required this.description,
    required this.city,
    required this.address,
    required this.pictureId,
    required this.categories,
    required this.menus,
    required this.rating,
    required this.customerReviews,
  });

  factory RestaurantDetail.fromJson(Map<String, dynamic> json) {
    return RestaurantDetail(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      city: json['city'] ?? '',
      address: json['address'] ?? '',
      pictureId: json['pictureId'] ?? '',
      categories:
          (json['categories'] as List<dynamic>?)
              ?.map((e) => Category.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      menus: Menus.fromJson(json['menus'] ?? {}),
      rating: (json['rating'] ?? 0).toDouble(),
      customerReviews:
          (json['customerReviews'] as List<dynamic>?)
              ?.map((e) => CustomerReview.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  // Convert RestaurantDetail to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'city': city,
      'address': address,
      'pictureId': pictureId,
      'categories': categories.map((e) => e.toJson()).toList(),
      'menus': menus.toJson(),
      'rating': rating,
      'customerReviews': customerReviews.map((e) => e.toJson()).toList(),
    };
  }

  String get pictureUrl => ConstantData.getMediumImageUrl(pictureId);
}

class Category {
  final String name;

  Category({required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(name: json['name'] ?? '');
  }

  // Convert Category to JSON
  Map<String, dynamic> toJson() {
    return {'name': name};
  }
}

class Menus {
  final List<MenuItem> foods;
  final List<MenuItem> drinks;

  Menus({required this.foods, required this.drinks});

  factory Menus.fromJson(Map<String, dynamic> json) {
    return Menus(
      foods:
          (json['foods'] as List<dynamic>?)
              ?.map((e) => MenuItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      drinks:
          (json['drinks'] as List<dynamic>?)
              ?.map((e) => MenuItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  // Convert Menus to JSON
  Map<String, dynamic> toJson() {
    return {
      'foods': foods.map((e) => e.toJson()).toList(),
      'drinks': drinks.map((e) => e.toJson()).toList(),
    };
  }
}

class MenuItem {
  final String name;

  MenuItem({required this.name});

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(name: json['name'] ?? '');
  }

  // Convert MenuItem to JSON
  Map<String, dynamic> toJson() {
    return {'name': name};
  }
}

class RestaurantDetailResponse {
  final bool error;
  final String message;
  final RestaurantDetail restaurant;

  RestaurantDetailResponse({
    required this.error,
    required this.message,
    required this.restaurant,
  });

  factory RestaurantDetailResponse.fromJson(Map<String, dynamic> json) {
    return RestaurantDetailResponse(
      error: json['error'] ?? false,
      message: json['message'] ?? '',
      restaurant: RestaurantDetail.fromJson(json['restaurant'] ?? {}),
    );
  }
}
