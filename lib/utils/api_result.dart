sealed class ApiResult<T> {
  const ApiResult();
}

final class ApiLoading<T> extends ApiResult<T> {
  const ApiLoading();
}

final class ApiSuccess<T> extends ApiResult<T> {
  final T data;

  const ApiSuccess({required this.data});
}

final class ApiFailure<T> extends ApiResult<T> {
  final String message;
  final int? statusCode;
  final Exception? exception;

  const ApiFailure({required this.message, this.statusCode, this.exception});

  @override
  String toString() => 'ApiFailure(message: $message, statusCode: $statusCode)';
}

final class ApiEmpty<T> extends ApiResult<T> {
  final String message;

  const ApiEmpty({required this.message});
}

extension ApiResultExtension<T> on ApiResult<T> {
  bool get isLoading => this is ApiLoading<T>;

  bool get isSuccess => this is ApiSuccess<T>;

  bool get isFailure => this is ApiFailure<T>;

  bool get isEmpty => this is ApiEmpty<T>;

  T? get dataOrNull => switch (this) {
    ApiSuccess<T>(:final data) => data,
    _ => null,
  };

  String? get errorOrNull => switch (this) {
    ApiFailure<T>(:final message) => message,
    ApiEmpty<T>(:final message) => message,
    _ => null,
  };

  ApiResult<R> map<R>(R Function(T data) transform) => switch (this) {
    ApiLoading<T>() => ApiLoading<R>(),
    ApiSuccess<T>(:final data) => ApiSuccess<R>(data: transform(data)),
    ApiFailure<T>(:final message, :final statusCode, :final exception) =>
      ApiFailure<R>(
        message: message,
        statusCode: statusCode,
        exception: exception,
      ),
    ApiEmpty<T>(:final message) => ApiEmpty<R>(message: message),
  };

  R fold<R>({
    required R Function() onLoading,
    required R Function(T data) onSuccess,
    required R Function(String message) onFailure,
    required R Function(String message) onEmpty,
  }) => switch (this) {
    ApiLoading<T>() => onLoading(),
    ApiSuccess<T>(:final data) => onSuccess(data),
    ApiFailure<T>(:final message) => onFailure(message),
    ApiEmpty<T>(:final message) => onEmpty(message),
  };
}
