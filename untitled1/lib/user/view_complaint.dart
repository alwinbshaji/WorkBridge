import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ViewComplaintPage extends StatefulWidget {
  const ViewComplaintPage({super.key});

  @override
  State<ViewComplaintPage> createState() => _ViewComplaintPageState();
}

class _ViewComplaintPageState extends State<ViewComplaintPage> {
  List complaints = [];
  bool isLoading = true;

  Future<void> fetchComplaints() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String lid = sh.getString('lid') ?? "";
    String url = sh.getString('url') ?? "";

    if (!url.endsWith("/")) {
      url = "$url/";
    }

    final response = await http.post(
      Uri.parse(url + "user_view_complaint/"),
      body: {'lid': lid},
    );

    var jsonData = json.decode(response.body);

    if (jsonData['status'] == "ok") {
      setState(() {
        complaints = jsonData['data'];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchComplaints();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Complaints & Replies"),
        backgroundColor: const Color(0xFF14b8a6),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : complaints.isEmpty
          ? const Center(child: Text("No Complaints Found"))
          : ListView.builder(
        itemCount: complaints.length,
        itemBuilder: (context, index) {
          var c = complaints[index];

          return Card(
            margin: const EdgeInsets.all(10),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Date: ${c['date']}",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Complaint:",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold),
                  ),
                  Text(c['content']),
                  const SizedBox(height: 10),
                  const Divider(),
                  const Text(
                    "Admin Reply:",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green),
                  ),
                  Text(
                    c['reply'] == "pending"
                        ? "Waiting for reply..."
                        : c['reply'],
                    style: TextStyle(
                      color: c['reply'] == "pending"
                          ? Colors.orange
                          : Colors.black,
                    ),
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