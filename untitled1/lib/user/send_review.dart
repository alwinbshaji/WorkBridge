import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SendReviewPage extends StatefulWidget {
  const SendReviewPage({super.key});

  @override
  State<SendReviewPage> createState() => _SendReviewPageState();
}

class _SendReviewPageState extends State<SendReviewPage> {
  List workers = [];
  String? selectedWorkerId;
  String url = "";

  final TextEditingController ratingController = TextEditingController();
  final TextEditingController reviewController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadWorkers();
  }

  // 🔹 Load Accepted Workers for Dropdown (NO IP USED)
  Future<void> loadWorkers() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    url = sp.getString("url") ?? "";

    if (url.isEmpty) {
      Fluttertoast.showToast(msg: "Server URL not found");
      return;
    }

    try {
      final response = await http.get(
        Uri.parse("$url/user_get_accepted_workers/"),
      );

      final data = jsonDecode(response.body);

      if (data['status'] == 'ok') {
        setState(() {
          workers = data['data'];
        });
      } else {
        Fluttertoast.showToast(msg: "No workers found");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Connection Error");
    }
  }

  // 🔹 Send Review (USING URL)
  Future<void> sendReview() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String userId = sp.getString("lid") ?? "";

    if (selectedWorkerId == null) {
      Fluttertoast.showToast(msg: "Please select a worker");
      return;
    }

    if (ratingController.text.isEmpty ||
        reviewController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Fill all fields");
      return;
    }

    try {
      final response = await http.post(
        Uri.parse("$url/user_send_review/"),
        body: {
          "user_id": userId,
          "worker_id": selectedWorkerId,
          "rating": ratingController.text,
          "review": reviewController.text,
        },
      );

      final data = jsonDecode(response.body);

      if (data['status'] == 'ok') {
        Fluttertoast.showToast(msg: "Review Sent Successfully");

        ratingController.clear();
        reviewController.clear();

        setState(() {
          selectedWorkerId = null;
        });
      } else {
        Fluttertoast.showToast(msg: "Failed to send review");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Server Error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Send Review"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: workers.isEmpty
            ? const Center(child: Text("No Accepted Workers Available"))
            : Column(
          children: [
            // 🔹 Worker Dropdown (Accepted Workers Only)
            DropdownButtonFormField<String>(
              value: selectedWorkerId,
              hint: const Text("Select Worker"),
              items: workers.map<DropdownMenuItem<String>>((worker) {
                return DropdownMenuItem<String>(
                  value: worker['id'].toString(),
                  child: Text(worker['name']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedWorkerId = value;
                });
              },
              decoration: const InputDecoration(
                labelText: "Worker",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // 🔹 Rating Field
            TextField(
              controller: ratingController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Rating (1-5)",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // 🔹 Review Field
            TextField(
              controller: reviewController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Write Review",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            // 🔹 Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: sendReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  "Submit Review",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}