import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'add_review_screen.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  late Future<List<dynamic>> _reviews;

  @override
  void initState() {
    super.initState();
    _reviews = fetchReviews();
  }

  Future<void> _refresh() async {
    setState(() {
      _reviews = fetchReviews();
    });
  }

  void _navigateToAdd() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddReviewScreen(),
      ),
    );
    if (result == true) {
      setState(() {
        _reviews = fetchReviews();
      });
    }
  }

  Widget _buildStars(int rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        return Icon(
          i < rating ? Icons.star : Icons.star_outline,
          size: 14,
          color: i < rating
              ? const Color(0xFFFBBF24)
              : const Color(0xFF4B5563),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _reviews,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF6366F1)),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wifi_off, color: Color(0xFF6366F1), size: 48),
                const SizedBox(height: 16),
                const Text('Could not connect to server',
                    style: TextStyle(color: Colors.white70, fontSize: 16)),
                const SizedBox(height: 8),
                const Text('Make sure the backend is running',
                    style: TextStyle(color: Colors.white38, fontSize: 13)),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _refresh,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final reviews = snapshot.data!;

        if (reviews.isEmpty) {
          return Stack(
            children: [
              const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star_outline,
                        color: Color(0xFF6366F1), size: 48),
                    SizedBox(height: 16),
                    Text('No reviews yet',
                        style:
                            TextStyle(color: Colors.white70, fontSize: 16)),
                  ],
                ),
              ),
              Positioned(
                bottom: 24,
                right: 24,
                child: FloatingActionButton(
                  onPressed: _navigateToAdd,
                  backgroundColor: const Color(0xFF6366F1),
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ),
            ],
          );
        }

        return Stack(
          children: [
            RefreshIndicator(
              onRefresh: _refresh,
              color: const Color(0xFF6366F1),
              backgroundColor: const Color(0xFF111827),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                    vertical: 12, horizontal: 16),
                itemCount: reviews.length,
                itemBuilder: (context, index) {
                  final r = reviews[index];
                  final rating = r['rating'] as int? ?? 0;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111827),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: const Color(0xFF1E2030), width: 1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor:
                                        const Color(0xFF1E2030),
                                    child: Text(
                                      (r['customer_name'] ?? '?')[0]
                                          .toUpperCase(),
                                      style: const TextStyle(
                                          color: Color(0xFF6366F1),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    r['customer_name'] ?? '',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              _buildStars(rating),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            r['comment'] ?? '',
                            style: const TextStyle(
                                color: Colors.white60,
                                fontSize: 13,
                                height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              bottom: 24,
              right: 24,
              child: FloatingActionButton(
                onPressed: _navigateToAdd,
                backgroundColor: const Color(0xFF6366F1),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}