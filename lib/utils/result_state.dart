enum ResultState {
  loading,
  noData,
  hasData,
  error,
}

class Result<T> {
  final ResultState state;
  final String message;
  final T? data;

  Result.loading({this.message = 'Loading...'})
      : state = ResultState.loading,
        data = null;

  Result.hasData(this.data)
      : state = ResultState.hasData,
        message = '';

  Result.noData({this.message = 'No Data Available'})
      : state = ResultState.noData,
        data = null;

  Result.error({required this.message})
      : state = ResultState.error,
        data = null;
}
