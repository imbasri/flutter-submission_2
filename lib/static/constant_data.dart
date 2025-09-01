class ConstantData {
  static const String baseUrl = 'https://restaurant-api.dicoding.dev';

  static const String restaurantListEndpoint = '/list';
  static const String restaurantDetailEndpoint = '/detail';
  static const String restaurantSearchEndpoint = '/search';
  static const String restaurantReviewEndpoint = '/review';

  static String getSmallImageUrl(String pictureId) =>
      '$baseUrl/images/small/$pictureId';
  static String getMediumImageUrl(String pictureId) =>
      '$baseUrl/images/medium/$pictureId';
  static String getLargeImageUrl(String pictureId) =>
      '$baseUrl/images/large/$pictureId';
}
