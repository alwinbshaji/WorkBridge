
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WorkerViewRequests extends StatefulWidget {
  const WorkerViewRequests({super.key});

  @override
  State<WorkerViewRequests> createState() => _WorkerViewRequestsState();
}

class _WorkerViewRequestsState extends State<WorkerViewRequests> {
  List requestList = [];
  bool isLoading = true;

  static const Color bgColor = Color(0xFF0D0D12);
  static const Color cardColor = Color(0xFF17171F);
  static const Color purple = Color(0xFF7C3AED);
  static const Color lightPurple = Color(0xFFA855F7);
  static const Color whiteText = Colors.white;
  static const Color subText = Color(0xFFB8B8C2);

  @override
  void initState() {
    super.initState();
    loadRequests();
  }

  Future<void> loadRequests() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String url = sp.getString('url') ?? "";
    String lid = sp.getString('lid') ?? "";

    final response = await http.post(
      Uri.parse("$url/worker_view_requests/"),
      body: {'lid': lid},
    );

    final data = jsonDecode(response.body);

    if (data['status'] == 'ok') {
      setState(() {
        requestList = data['data'];
        isLoading = false;
      });
    }
  }

  Future<void> acceptRequest(String rid) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String url = sp.getString('url') ?? "";

    await http.post(
      Uri.parse("$url/worker_accept_request/"),
      body: {'rid': rid},
    );

    Fluttertoast.showToast(msg: "Request Accepted");
    loadRequests();
  }

  Future<void> rejectRequest(String rid) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String url = sp.getString('url') ?? "";

    await http.post(
      Uri.parse("$url/worker_reject_request/"),
      body: {'rid': rid},
    );

    Fluttertoast.showToast(msg: "Request Rejected");
    loadRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text(
          "Work Requests",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: lightPurple,
        ),
      )
          : requestList.isEmpty
          ? const Center(
        child: Text(
          "No Pending Requests",
          style: TextStyle(color: whiteText),
        ),
      )
          : ListView.builder(
        itemCount: requestList.length,
        itemBuilder: (context, index) {
          final request = requestList[index];

          return Card(
            color: cardColor,
            margin: const EdgeInsets.all(10),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "User: ${request['username']}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: whiteText,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Job: ${request['job']}",
                    style: const TextStyle(color: subText),
                  ),
                  Text(
                    "Amount: ₹${request['amount']}",
                    style: const TextStyle(color: subText),
                  ),
                  const Divider(color: Colors.white24),
                  Text(
                    "Date: ${request['date']}",
                    style: const TextStyle(color: subText),
                  ),
                  Text(
                    "Time: ${request['time']}",
                    style: const TextStyle(color: subText),
                  ),
                  Text(
                    "Place: ${request['place']}",
                    style: const TextStyle(color: subText),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "Description:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: whiteText,
                    ),
                  ),
                  Text(
                    request['description'],
                    style: const TextStyle(color: subText),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          acceptRequest(request['id'].toString());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: purple,
                        ),
                        child: const Text(
                          "Accept",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          rejectRequest(request['id'].toString());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text(
                          "Reject",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}