

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AcceptedWorkPage extends StatefulWidget {
  const AcceptedWorkPage({super.key});

  @override
  State<AcceptedWorkPage> createState() => _AcceptedWorkPageState();
}

class _AcceptedWorkPageState extends State<AcceptedWorkPage> {
  List acceptedList = [];
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
    loadAcceptedWork();
  }

  Future<void> loadAcceptedWork() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String url = sp.getString('url') ?? "";
    String lid = sp.getString('lid') ?? "";

    final response = await http.post(
      Uri.parse("$url/worker_view_accepted/"),
      body: {'lid': lid},
    );

    var jsonData = jsonDecode(response.body);

    if (jsonData['status'] == 'ok') {
      setState(() {
        acceptedList = jsonData['data'];
        isLoading = false;
      });
    } else {
      setState(() {
        acceptedList = [];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,

      appBar: AppBar(
        title: const Text(
          "Accepted Works",
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
          : acceptedList.isEmpty
          ? const Center(
        child: Text(
          "No Accepted Works",
          style: TextStyle(color: whiteText),
        ),
      )
          : ListView.builder(
        itemCount: acceptedList.length,
        itemBuilder: (context, index) {
          final item = acceptedList[index];

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
                    "User: ${item['username']}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: whiteText,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "Job: ${item['job']}",
                    style: const TextStyle(color: subText),
                  ),
                  Text(
                    "Amount: ₹${item['amount']}",
                    style: const TextStyle(color: subText),
                  ),

                  const Divider(color: Colors.white24),

                  Text(
                    "Date: ${item['date']}",
                    style: const TextStyle(color: subText),
                  ),
                  Text(
                    "Time: ${item['time']}",
                    style: const TextStyle(color: subText),
                  ),
                  Text(
                    "Place: ${item['place']}",
                    style: const TextStyle(color: subText),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    "Description:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: whiteText,
                    ),
                  ),

                  Text(
                    item['description'],
                    style: const TextStyle(color: subText),
                  ),

                  const SizedBox(height: 10),

                  const Chip(
                    label: Text("ACCEPTED"),
                    backgroundColor: lightPurple, // 👈 themed
                    labelStyle: TextStyle(color: Colors.white),
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