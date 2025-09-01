sealed class ApiOperation {
  const ApiOperation();
}

sealed class RestaurantListOperation extends ApiOperation {
  const RestaurantListOperation();
}

final class GetAllRestaurants extends RestaurantListOperation {
  const GetAllRestaurants();
}

final class SearchRestaurants extends RestaurantListOperation {
  final String query;

  const SearchRestaurants(this.query);
}

sealed class RestaurantDetailOperation extends ApiOperation {
  const RestaurantDetailOperation();
}

final class GetRestaurantDetail extends RestaurantDetailOperation {
  final String restaurantId;

  const GetRestaurantDetail(this.restaurantId);
}

sealed class ReviewOperation extends ApiOperation {
  const ReviewOperation();
}

final class AddReview extends ReviewOperation {
  final String restaurantId;
  final String name;
  final String review;

  const AddReview({
    required this.restaurantId,
    required this.name,
    required this.review,
  });
}

sealed class ApiRequest {
  const ApiRequest();

  static ApiRequest fromOperation(ApiOperation operation) {
    return switch (operation) {
      GetAllRestaurants() => const GetRestaurantsRequest(),
      SearchRestaurants(:final query) => SearchRestaurantsRequest(query: query),
      GetRestaurantDetail(:final restaurantId) => GetRestaurantDetailRequest(
        id: restaurantId,
      ),
      AddReview(:final restaurantId, :final name, :final review) =>
        AddReviewRequest(
          restaurantId: restaurantId,
          name: name,
          review: review,
        ),
    };
  }
}

final class GetRestaurantsRequest extends ApiRequest {
  const GetRestaurantsRequest();
}

final class SearchRestaurantsRequest extends ApiRequest {
  final String query;

  const SearchRestaurantsRequest({required this.query});
}

final class GetRestaurantDetailRequest extends ApiRequest {
  final String id;

  const GetRestaurantDetailRequest({required this.id});
}

final class AddReviewRequest extends ApiRequest {
  final String restaurantId;
  final String name;
  final String review;

  const AddReviewRequest({
    required this.restaurantId,
    required this.name,
    required this.review,
  });

  Map<String, String> toJson() => {
    'id': restaurantId,
    'name': name,
    'review': review,
  };
}
