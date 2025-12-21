import 'package:flutter/material.dart';
import 'package:olrggmobile/Rating/models/rating_entry.dart';
import 'package:olrggmobile/Rating/widgets/rating_entry_card.dart';
import 'package:olrggmobile/Rating/screens/rating_form.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RatingsSection extends StatefulWidget {
  final String newsId;

  const RatingsSection({super.key, required this.newsId});

  @override
  State<RatingsSection> createState() => _RatingsSectionState();
}

class _RatingsSectionState extends State<RatingsSection> {
  Future<List<RatingEntry>> fetchRatings(CookieRequest request) async {
    try {
      final response = await request.get(
        'http://localhost:8000/rating/json/${widget.newsId}/',
      );

      List<RatingEntry> listRatings = [];
      for (var d in response) {
        if (d != null) {
          listRatings.add(RatingEntry.fromJson(d));
        }
      }
      return listRatings;
    } catch (e) {
      print("Error fetching ratings: $e");
      return [];
    }
  }

  Future<void> _deleteRating(CookieRequest request, dynamic ratingId) async {
    try {
      final url = Uri.parse("http://localhost:8000/rating/delete/$ratingId/");

      // Get cookies from CookieRequest for authentication
      final cookies = request.headers['cookie'] ?? '';

      final httpResponse = await http.delete(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Cookie': cookies,
        },
      );

      if (context.mounted) {
        if (httpResponse.statusCode == 200) {
          final response = jsonDecode(httpResponse.body);
          if (response['status'] == 'success') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Rating berhasil dihapus")),
            );
            setState(() {}); // Refresh the list
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(response['message'] ?? "Gagal menghapus rating")),
            );
          }
        } else if (httpResponse.statusCode == 204) {
          // 204 No Content - successful deletion
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Rating berhasil dihapus")),
          );
          setState(() {}); // Refresh the list
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Gagal menghapus rating. Status: ${httpResponse.statusCode}")),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error menghapus rating: $e")),
        );
      }
    }
  }

  Future<void> _navigateToForm({dynamic ratingId, int? initialRating, String? initialReview}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RatingFormPage(
          newsId: widget.newsId,
          ratingId: ratingId,
          initialRating: initialRating,
          initialReview: initialReview,
        ),
      ),
    );

    if (result == true) {
      setState(() {}); // Refresh the list
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.yellow.shade200,
        border: Border(
          top: BorderSide(
            color: Colors.yellow.shade600,
            width: 2,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Ratings",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                ),
                onPressed: () => _navigateToForm(),
                icon: const Icon(Icons.add, size: 18),
                label: const Text("Add Rating"),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FutureBuilder<List<RatingEntry>>(
            future: fetchRatings(request),
            builder: (context, AsyncSnapshot<List<RatingEntry>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.rate_review_outlined,
                          size: 48,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Belum ada rating untuk berita ini.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Jadilah yang pertama memberi rating!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: snapshot.data!.length,
                itemBuilder: (_, index) {
                  final rating = snapshot.data![index];
                  return RatingEntryCard(
                    rating: rating,
                    onDelete: () => _deleteRating(request, rating.id),
                    onEdit: () => _navigateToForm(
                      ratingId: rating.id,
                      initialRating: rating.rating,
                      initialReview: rating.review,
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

