
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class WorkerViewReviewsPage extends StatefulWidget {
  const WorkerViewReviewsPage({Key? key}) : super(key: key);

  @override
  State<WorkerViewReviewsPage> createState() =>
      _WorkerViewReviewsPageState();
}

class _WorkerViewReviewsPageState
    extends State<WorkerViewReviewsPage> {
  List reviews = [];
  bool isLoading = true;
  String message = "";

  static const Color bgColor = Color(0xFF0D0D12);
  static const Color cardColor = Color(0xFF17171F);
  static const Color purple = Color(0xFF7C3AED);
  static const Color lightPurple = Color(0xFFA855F7);
  static const Color whiteText = Colors.white;
  static const Color subText = Color(0xFFB8B8C2);

  @override
  void initState() {
    super.initState();
    fetchReviews();
  }

  Future<void> fetchReviews() async {
    try {
      SharedPreferences sh =
      await SharedPreferences.getInstance();
      String url = sh.getString('url') ?? "";
      String lid = sh.getString('lid') ?? "";

      if (url.isEmpty || lid.isEmpty) {
        setState(() {
          message = "Missing URL or Login ID";
          isLoading = false;
        });
        return;
      }

      final uri =
      Uri.parse('$url/worker_view_reviews/');

      final response = await http.post(uri, body: {
        'lid': lid,
      });

      print("Review API Response: ${response.body}");

      var data = json.decode(response.body);

      if (data['status'] == 'ok') {
        setState(() {
          reviews = data['data'];
          isLoading = false;
        });
      } else {
        setState(() {
          message = data['error'] ?? "No Reviews Found";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        message = "Error: $e";
        isLoading = false;
      });
    }
  }

  Widget buildStars(String rating) {
    int rate = int.tryParse(rating) ?? 0;

    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rate ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 20,
        );
      }),
    );
  }

  Widget reviewCard(int index) {
    final review = reviews[index];

    return Card(
      color: cardColor,
      elevation: 4,
      margin: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "User: ${review['user_name']}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: whiteText,
              ),
            ),
            const SizedBox(height: 6),
            buildStars(review['rating'] ?? "0"),
            const SizedBox(height: 8),
            Text(
              "Review: ${review['review']}",
              style: const TextStyle(
                fontSize: 16,
                color: subText,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Date: ${review['date']}",
              style: const TextStyle(
                fontSize: 14,
                color: subText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text(
          "User Reviews",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() {
                isLoading = true;
              });
              fetchReviews();
            },
          )
        ],
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: lightPurple,
        ),
      )
          : reviews.isEmpty
          ? Center(
        child: Text(
          message.isEmpty
              ? "No Reviews Received Yet"
              : message,
          style: const TextStyle(
            fontSize: 18,
            color: whiteText,
          ),
        ),
      )
          : RefreshIndicator(
        color: lightPurple,
        onRefresh: fetchReviews,
        child: ListView.builder(
          itemCount: reviews.length,
          itemBuilder: (context, index) {
            return reviewCard(index);
          },
        ),
      ),
    );
  }
}