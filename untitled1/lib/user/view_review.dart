import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ViewReviewPage extends StatefulWidget {
  const ViewReviewPage({super.key});

  @override
  State<ViewReviewPage> createState() => _ViewReviewPageState();
}

class _ViewReviewPageState extends State<ViewReviewPage> {
  List reviews = [];
  String baseUrl = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadReviews();
  }

  Future<void> loadReviews() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    baseUrl = sh.getString("url") ?? "";
    String lid = sh.getString("lid") ?? "";

    if (!baseUrl.endsWith("/")) {
      baseUrl = "$baseUrl/";
    }

    final response = await http.post(
      Uri.parse(baseUrl + "user_view_review/"),
      body: {"lid": lid},
    );

    var jsonData = json.decode(response.body);

    if (jsonData["status"] == "ok") {
      setState(() {
        reviews = jsonData["data"];
        isLoading = false;
      });
    } else {
      isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Reviews"),
        backgroundColor: Colors.amber,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : reviews.isEmpty
          ? const Center(child: Text("No Reviews Found"))
          : ListView.builder(
        itemCount: reviews.length,
        itemBuilder: (context, index) {
          var r = reviews[index];
          return Card(
            margin: const EdgeInsets.all(12),
            child: ListTile(
              leading:
              const Icon(Icons.star, color: Colors.amber),
              title: Text(
                r["worker_name"],
                style: const TextStyle(
                    fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text("Job: ${r["job"]}"),
                  Text("Rating: ${r["rating"]}"),
                  Text("Review: ${r["review"]}"),
                  Text("Date: ${r["date"]}"),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}