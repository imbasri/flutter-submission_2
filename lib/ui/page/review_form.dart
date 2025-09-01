import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/review_provider.dart';
import '../../utils/result_state.dart';
class ReviewForm extends StatefulWidget {
  final String restaurantId;
  final String restaurantName;
  const ReviewForm({
    super.key,
    required this.restaurantId,
    required this.restaurantName,
  });
  @override
  State<ReviewForm> createState() => _ReviewFormState();
}
class _ReviewFormState extends State<ReviewForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _reviewController = TextEditingController();
  bool _hasNavigatedBack = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReviewProvider>(context, listen: false).resetState();
    });
  }
  @override
  void dispose() {
    _nameController.dispose();
    _reviewController.dispose();
    super.dispose();
  }
  void _submitReview() async {
    if (_formKey.currentState!.validate()) {
      await Provider.of<ReviewProvider>(context, listen: false).addReview(
        widget.restaurantId,
        _nameController.text,
        _reviewController.text,
      );
      
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Review'),
      ),
      body: Consumer<ReviewProvider>(
        builder: (context, provider, child) {
          if (provider.result.state == ResultState.hasData && !_hasNavigatedBack) {
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              _hasNavigatedBack = true;
              
              provider.resetState();
              
              Navigator.pop(context, true);
            });
          }
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add a review for ${widget.restaurantName}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Your Name',
                      hintText: 'Enter your name',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your name';
                      }
                      if (value.trim().length < 2) {
                        return 'Name must be at least 2 characters';
                      }
                      return null;
                    },
                    enabled: !provider.isSubmitting,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _reviewController,
                    decoration: const InputDecoration(
                      labelText: 'Your Review',
                      hintText: 'Share your experience...',
                      prefixIcon: Icon(Icons.rate_review),
                    ),
                    maxLines: 5,
                    maxLength: 500,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your review';
                      }
                      if (value.trim().length < 10) {
                        return 'Review must be at least 10 characters';
                      }
                      return null;
                    },
                    enabled: !provider.isSubmitting,
                  ),
                  const SizedBox(height: 24),
                  if (provider.result.state == ResultState.error) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error, color: Colors.red.shade700),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              provider.result.message,
                              style: TextStyle(color: Colors.red.shade700),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: provider.isSubmitting ? null : _submitReview,
                      child: provider.isSubmitting
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text('Submitting...'),
                              ],
                            )
                          : const Text('Submit Review'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '* Your review will be publicly visible to other users',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
