import 'package:flutter/foundation.dart';
import '../data/api/api_service.dart';
import '../data/model/review.dart';
import '../utils/api_result.dart';
import '../utils/api_operations.dart';

class ReviewProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  ApiResult<List<CustomerReview>> _addReviewResult = const ApiEmpty(
    message: '',
  );
  bool _isSubmitting = false;
  String? _lastRestaurantId;

  ApiResult<List<CustomerReview>> get result => _addReviewResult;
  bool get isSubmitting => _isSubmitting;
  String? get lastRestaurantId => _lastRestaurantId;
  Future<bool> addReview(
    String restaurantId,
    String name,
    String review,
  ) async {
    try {
      if (name.trim().isEmpty || review.trim().isEmpty) {
        _addReviewResult = const ApiFailure(
          message: 'Nama dan review tidak boleh kosong',
        );
        notifyListeners();
        return false;
      }
      _isSubmitting = true;
      _lastRestaurantId = restaurantId;
      _addReviewResult = const ApiLoading();
      notifyListeners();

      final operation = AddReview(
        restaurantId: restaurantId,
        name: name.trim(),
        review: review.trim(),
      );

      final apiResult = await _apiService.callApi<ReviewResponse>(operation);

      bool success = false;

      switch (apiResult) {
        case ApiLoading<ReviewResponse>():
          _addReviewResult = const ApiLoading();
          success = false;

        case ApiSuccess<ReviewResponse>(:final data):
          if (data.error) {
            _addReviewResult = ApiFailure(message: data.message);
            success = false;
          } else {
            _addReviewResult = ApiSuccess(data: data.customerReviews);
            success = true;
          }

        case ApiFailure<ReviewResponse>(:final message):
          _addReviewResult = ApiFailure(message: message);
          success = false;

        case ApiEmpty<ReviewResponse>(:final message):
          _addReviewResult = ApiFailure(message: message);
          success = false;
      }

      _isSubmitting = false;
      notifyListeners();

      return success;
    } catch (e) {
      _isSubmitting = false;
      _addReviewResult = const ApiFailure(
        message:
            'Terjadi kesalahan saat menambahkan review. Silakan coba lagi.',
      );
      notifyListeners();
      return false;
    }
  }

  void clearResult() {
    _addReviewResult = const ApiEmpty(message: '');
    _lastRestaurantId = null;
    notifyListeners();
  }

  void resetSubmittingState() {
    _isSubmitting = false;
    notifyListeners();
  }

  void resetState() {
    clearResult();
    resetSubmittingState();
  }

  List<CustomerReview>? get currentReviews {
    return _addReviewResult.isSuccess ? _addReviewResult.dataOrNull : null;
  }
}
