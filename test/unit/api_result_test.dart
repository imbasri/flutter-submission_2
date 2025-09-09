import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pemula/utils/api_result.dart';

void main() {
  group('ApiResult Unit Tests', () {
    test('ApiSuccess should contain data', () {
      // Arrange
      const testData = 'test data';
      
      // Act
      const result = ApiSuccess(data: testData);
      
      // Assert
      expect(result.data, equals(testData));
      expect(result.isSuccess, isTrue);
      expect(result.isLoading, isFalse);
      expect(result.isFailure, isFalse);
      expect(result.isEmpty, isFalse);
      expect(result.dataOrNull, equals(testData));
    });

    test('ApiFailure should contain error message', () {
      // Arrange
      const errorMessage = 'Something went wrong';
      
      // Act
      const result = ApiFailure<String>(message: errorMessage);
      
      // Assert
      expect(result.message, equals(errorMessage));
      expect(result.isFailure, isTrue);
      expect(result.isSuccess, isFalse);
      expect(result.isLoading, isFalse);
      expect(result.isEmpty, isFalse);
      expect(result.dataOrNull, isNull);
      expect(result.errorOrNull, equals(errorMessage));
    });

    test('ApiLoading should have correct state', () {
      // Act
      const result = ApiLoading<String>();
      
      // Assert
      expect(result.isLoading, isTrue);
      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isFalse);
      expect(result.isEmpty, isFalse);
      expect(result.dataOrNull, isNull);
    });

    test('ApiEmpty should contain empty message', () {
      // Arrange
      const emptyMessage = 'No data found';
      
      // Act
      const result = ApiEmpty<String>(message: emptyMessage);
      
      // Assert
      expect(result.message, equals(emptyMessage));
      expect(result.isEmpty, isTrue);
      expect(result.isSuccess, isFalse);
      expect(result.isLoading, isFalse);
      expect(result.isFailure, isFalse);
      expect(result.dataOrNull, isNull);
      expect(result.errorOrNull, equals(emptyMessage));
    });

    test('map function should transform data correctly', () {
      // Arrange
      const originalResult = ApiSuccess(data: 5);
      
      // Act
      final mappedResult = originalResult.map<String>((data) => 'Number: $data');
      
      // Assert
      expect(mappedResult, isA<ApiSuccess<String>>());
      expect(mappedResult.dataOrNull, equals('Number: 5'));
    });

    test('fold function should handle all states correctly', () {
      // Arrange
      const loadingResult = ApiLoading<String>();
      const successResult = ApiSuccess(data: 'success');
      const failureResult = ApiFailure<String>(message: 'error');
      const emptyResult = ApiEmpty<String>(message: 'empty');
      
      // Act & Assert
      final loadingFold = loadingResult.fold(
        onLoading: () => 'loading',
        onSuccess: (data) => 'success: $data',
        onFailure: (message) => 'failure: $message',
        onEmpty: (message) => 'empty: $message',
      );
      expect(loadingFold, equals('loading'));
      
      final successFold = successResult.fold(
        onLoading: () => 'loading',
        onSuccess: (data) => 'success: $data',
        onFailure: (message) => 'failure: $message',
        onEmpty: (message) => 'empty: $message',
      );
      expect(successFold, equals('success: success'));
      
      final failureFold = failureResult.fold(
        onLoading: () => 'loading',
        onSuccess: (data) => 'success: $data',
        onFailure: (message) => 'failure: $message',
        onEmpty: (message) => 'empty: $message',
      );
      expect(failureFold, equals('failure: error'));
      
      final emptyFold = emptyResult.fold(
        onLoading: () => 'loading',
        onSuccess: (data) => 'success: $data',
        onFailure: (message) => 'failure: $message',
        onEmpty: (message) => 'empty: $message',
      );
      expect(emptyFold, equals('empty: empty'));
    });
  });
}
