import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RatingFormPage extends StatefulWidget {
  final String newsId;
  final dynamic ratingId;
  final int? initialRating;
  final String? initialReview;

  const RatingFormPage({
    super.key,
    required this.newsId,
    this.ratingId,
    this.initialRating,
    this.initialReview,
  });

  @override
  State<RatingFormPage> createState() => _RatingFormPageState();
}

class _RatingFormPageState extends State<RatingFormPage> {
  final _formKey = GlobalKey<FormState>();
  late int _rating;
  late String _review;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating ?? 5;
    _review = widget.initialReview ?? "";
  }

  bool get isEditing => widget.ratingId != null;

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: Colors.blue[300],
      appBar: AppBar(
        title: Text(
          isEditing ? "Edit Rating" : "Add Rating",
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.yellow[700],
        foregroundColor: Colors.black,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Rating Score Slider
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade900, width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Rating: $_rating / 5",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                    Slider(
                      value: _rating.toDouble(),
                      min: 1,
                      max: 5,
                      divisions: 4,
                      label: _rating.toString(),
                      onChanged: (double value) {
                        setState(() {
                          _rating = value.toInt();
                        });
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return Icon(
                          index < _rating ? Icons.star : Icons.star_border,
                          color: Colors.yellow[700],
                          size: 32,
                        );
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Review Text Field
              TextFormField(
                initialValue: _review,
                decoration: InputDecoration(
                  hintText: "Tulis review Anda di sini...",
                  labelText: "Review",
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                    borderSide: BorderSide(
                      color: Colors.blue.shade900,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                    borderSide: BorderSide(
                      color: Colors.blue.shade900,
                      width: 2.0,
                    ),
                  ),
                ),
                maxLines: 5,
                onChanged: (String? value) {
                  setState(() {
                    _review = value!;
                  });
                },
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return "Review tidak boleh kosong!";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;

                    try {
                      dynamic response;

                      if (isEditing) {
                        // Edit existing rating - use CookieRequest.post() for proper authentication
                        response = await request.post(
                          "https://davin-fauzan-olr-gg.pbp.cs.ui.ac.id/rating/edit/${widget.ratingId}/",
                          {"rating": _rating.toString(), "review": _review},
                        );
                      } else {
                        // Create new rating - use POST method (CookieRequest works fine)
                        response = await request.post(
                          "https://davin-fauzan-olr-gg.pbp.cs.ui.ac.id/rating/add/${widget.newsId}/",
                          {"rating": _rating.toString(), "review": _review},
                        );
                      }

                      if (context.mounted) {
                        if (response["status"] == "success") {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isEditing
                                    ? "Rating berhasil diupdate!"
                                    : "Rating berhasil ditambahkan!",
                              ),
                            ),
                          );
                          Navigator.pop(context, true);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                response["message"] ??
                                    "Gagal menyimpan rating, coba lagi.",
                              ),
                            ),
                          );
                        }
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text("Error: $e")));
                      }
                    }
                  },
                  child: Text(
                    isEditing ? "Simpan Perubahan" : "Tambah Rating",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
