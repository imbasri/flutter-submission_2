class CustomerReview {
  final String name;
  final String review;
  final String date;

  CustomerReview({
    required this.name,
    required this.review,
    required this.date,
  });

  factory CustomerReview.fromJson(Map<String, dynamic> json) {
    return CustomerReview(
      name: json['name'] ?? '',
      review: json['review'] ?? '',
      date: json['date'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'review': review, 'date': date};
  }
}

class ReviewRequest {
  final String id;
  final String name;
  final String review;

  ReviewRequest({required this.id, required this.name, required this.review});

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'review': review};
  }
}

class ReviewResponse {
  final bool error;
  final String message;
  final List<CustomerReview> customerReviews;

  ReviewResponse({
    required this.error,
    required this.message,
    required this.customerReviews,
  });

  factory ReviewResponse.fromJson(Map<String, dynamic> json) {
    return ReviewResponse(
      error: json['error'] ?? false,
      message: json['message'] ?? '',
      customerReviews:
          (json['customerReviews'] as List<dynamic>?)
              ?.map((e) => CustomerReview.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
