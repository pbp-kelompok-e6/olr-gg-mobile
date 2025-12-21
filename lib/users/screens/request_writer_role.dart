import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:olrggmobile/widgets/left_drawer.dart'; 

class RequestWriterPage extends StatefulWidget {
  const RequestWriterPage({super.key});

  @override
  State<RequestWriterPage> createState() => _RequestWriterPageState();
}

class _RequestWriterPageState extends State<RequestWriterPage> {
  final _formKey = GlobalKey<FormState>();
  String _reason = "";
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Writer Role'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Request to be a Writer",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Explain the reason why you are interested to become a writer at OLR.gg.",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              
              // input
              TextFormField(
                decoration: InputDecoration(
                  hintText: "Explain why you want to be a writer at OLR.GG.",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                maxLines: 5,
                onChanged: (String? value) {
                  setState(() {
                    _reason = value!;
                  });
                },
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return "You have to have a reason!";
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 24),
              
              // submit
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _isLoading 
                    ? null 
                    : () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() { _isLoading = true; });
                        try {
                          final response = await request.post(
                            "https://davin-fauzan-olr-gg.pbp.cs.ui.ac.id/users/api/request-writer-role/",
                            {
                              'reason': _reason,
                            },
                          );

                          if (!context.mounted) return;

                          if (response['status'] == 'success') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(response['message']),
                                backgroundColor: Colors.green,
                              ),
                            );
                            await Future.delayed(const Duration(seconds: 2));
          
                            if (!context.mounted) return;
                            Navigator.pop(context);
                          } else {
                            String errMessage = response['message'] ?? "There was an error.";
                            if (response['errors'] != null) {
                               errMessage = "Invalid request.";
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(errMessage),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                             SnackBar(
                              content: Text("Error: $e"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } finally {
                          if (mounted) setState(() { _isLoading = false; });
                        }
                      }
                  },
                  child: _isLoading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text(
                        "Send Request",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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