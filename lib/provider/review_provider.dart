import 'package:flutter/foundation.dart';
import '../data/api/api_service.dart';
import '../data/model/review.dart';
import '../utils/result_state.dart';
import '../utils/api_result.dart';
import '../utils/api_operations.dart';

class ReviewProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  Result<List<CustomerReview>> _addReviewResult = Result.noData();
  bool _isSubmitting = false;
  String? _lastRestaurantId;
  
  Result<List<CustomerReview>> get result => _addReviewResult;
  bool get isSubmitting => _isSubmitting;
  String? get lastRestaurantId => _lastRestaurantId;

  Future<bool> addReview(String restaurantId, String name, String review) async {
    try {
      // Validasi input
      if (name.trim().isEmpty || review.trim().isEmpty) {
        _addReviewResult = Result.error(message: 'Nama dan review tidak boleh kosong');
        notifyListeners();
        return false;
      }

      // Set loading state
      _isSubmitting = true;
      _lastRestaurantId = restaurantId;
      _addReviewResult = Result.loading();
      notifyListeners();
      
      // Buat operasi dengan sealed class
      final operation = AddReview(
        restaurantId: restaurantId,
        name: name.trim(),
        review: review.trim(),
      );
      
      final apiResult = await _apiService.callApi<ReviewResponse>(operation);
      
      bool success = false;
      
      switch (apiResult) {
        // Kalau masih loading
        case ApiLoading<ReviewResponse>():
          _addReviewResult = Result.loading();
          success = false;
          
        // Kalau berhasil dapat data
        case ApiSuccess<ReviewResponse>(:final data):
          if (data.error) {
            _addReviewResult = Result.error(message: data.message);
            success = false;
          } else {
            _addReviewResult = Result.hasData(data.customerReviews);
            success = true;
          }
          
        // Kalau ada error/gagal
        case ApiFailure<ReviewResponse>(:final message):
          _addReviewResult = Result.error(message: message);
          success = false;
          
        // Kalau data kosong
        case ApiEmpty<ReviewResponse>(:final message):
          _addReviewResult = Result.error(message: message);
          success = false;
      }
      
      _isSubmitting = false;
      notifyListeners();
      
      return success;
      
    } catch (e) {
      // Handle exception
      _isSubmitting = false;
      _addReviewResult = Result.error(message: 'Error menambah review: ${e.toString()}');
      notifyListeners();
      return false;
    }
  }

  // Clear result
  void clearResult() {
    _addReviewResult = Result.noData();
    _lastRestaurantId = null;
    notifyListeners();
  }

  // Reset submitting state
  void resetSubmittingState() {
    _isSubmitting = false;
    notifyListeners();
  }

  // Reset state - untuk backward compatibility
  void resetState() {
    clearResult();
    resetSubmittingState();
  }

  // Get current reviews jika ada
  List<CustomerReview>? get currentReviews {
    return _addReviewResult.state == ResultState.hasData 
        ? _addReviewResult.data 
        : null;
  }
}
