import 'package:flutter/material.dart';
import '../../data/model/review.dart';

class ReviewList extends StatelessWidget {
  final List<CustomerReview> reviews;

  const ReviewList({super.key, required this.reviews});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (reviews.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(
                Icons.rate_review_outlined,
                size: 64,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No reviews yet',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWeb = constraints.maxWidth > 600;

        return Container(
          constraints: BoxConstraints(maxHeight: isWeb ? 400 : 300),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            itemCount: reviews.length,
            separatorBuilder: (context, index) =>
                Divider(color: theme.dividerColor, thickness: 0.5),
            itemBuilder: (context, index) {
              final review = reviews[index];
              return Container(
                margin: EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: isWeb ? 16.0 : 0.0,
                ),
                padding: EdgeInsets.all(isWeb ? 20.0 : 16.0),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(
                    color: theme.dividerColor.withValues(alpha: 0.5),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.shadowColor.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: theme.primaryColor,
                          radius: isWeb ? 24 : 20,
                          child: Text(
                            review.name.isNotEmpty
                                ? review.name[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: isWeb ? 18 : 16,
                            ),
                          ),
                        ),
                        SizedBox(width: isWeb ? 16 : 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                review.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: isWeb ? 18 : 16,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                review.date,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                  fontSize: isWeb ? 13 : 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isWeb ? 12 : 8),
                    Padding(
                      padding: EdgeInsets.only(left: isWeb ? 56 : 52),
                      child: Text(
                        review.review,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: isWeb ? 15 : 14,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
