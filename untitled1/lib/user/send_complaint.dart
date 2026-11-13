import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SendComplaintPage extends StatefulWidget {
  const SendComplaintPage({super.key});

  @override
  State<SendComplaintPage> createState() => _SendComplaintPageState();
}

class _SendComplaintPageState extends State<SendComplaintPage> {
  final TextEditingController complaintController = TextEditingController();
  bool isLoading = false;

  Future<void> sendComplaint() async {
    if (complaintController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter complaint")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    SharedPreferences sh = await SharedPreferences.getInstance();
    String lid = sh.getString('lid') ?? "";
    String url = sh.getString('url') ?? "";

    if (!url.endsWith("/")) {
      url = "$url/";
    }

    final response = await http.post(
      Uri.parse(url + "user_send_complaint/"),
      body: {
        'lid': lid,
        'content': complaintController.text,
      },
    );

    var jsonData = json.decode(response.body);

    setState(() {
      isLoading = false;
    });

    if (jsonData['status'] == "ok") {
      complaintController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Complaint Sent Successfully"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to Send Complaint"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    complaintController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Send Complaint"),
        backgroundColor: const Color(0xFF14b8a6),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: complaintController,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: "Enter your complaint",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF14b8a6),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: isLoading ? null : sendComplaint,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  "Submit Complaint",
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}