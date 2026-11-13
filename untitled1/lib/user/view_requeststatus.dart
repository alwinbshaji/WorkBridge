
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'payment.dart';

class ViewRequestStatusPage extends StatefulWidget {
  const ViewRequestStatusPage({super.key});

  @override
  State<ViewRequestStatusPage> createState() => _ViewRequestStatusPageState();
}

class _ViewRequestStatusPageState extends State<ViewRequestStatusPage> {

  List requestList = [];
  bool isLoading = true;
  String baseUrl = "";

  @override
  void initState() {
    super.initState();
    loadRequests();
  }

  Future<void> loadRequests() async {

    SharedPreferences sp = await SharedPreferences.getInstance();

    baseUrl = sp.getString('url') ?? "";
    String lid = sp.getString('lid') ?? "";

    final response = await http.post(
      Uri.parse("${baseUrl}/user_view_request_status/"),
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

  // CALL FUNCTION
  Future<void> callWorker(String phone) async {

    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Phone number not available")),
      );
      return;
    }

    final Uri url = Uri(scheme: 'tel', path: phone);


      await launchUrl(url);

  }

  Widget requestCard(int index) {

    final req = requestList[index];

    String status = req['status'] ?? "";
    String phone = req['phone'] ?? "";

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(12),

      child: Padding(
        padding: const EdgeInsets.all(14),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Text(
              "Worker: ${req['worker_name']}",
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            Text("Job: ${req['job']}"),
            Text("Amount: ₹${req['amount']}"),

            const SizedBox(height: 4),

            Text("Phone: $phone"),

            const Divider(),

            Text("Date: ${req['date']}"),
            Text("Time: ${req['time']}"),
            Text("Place: ${req['place']}"),

            const SizedBox(height: 8),

            const Text(
              "Description:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            Text(req['description'] ?? ""),

            const SizedBox(height: 10),

            // STATUS BADGE
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6),

              decoration: BoxDecoration(
                color: status == "accept"
                    ? Colors.green
                    : status == "pending"
                    ? Colors.orange
                    : Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),

              child: Text(
                status.toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),

            const SizedBox(height: 12),

            if (status == "accept")

              Row(
                children: [

                  Expanded(
                    child: ElevatedButton.icon(

                      icon: const Icon(Icons.call),

                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),

                      onPressed: () {
                        callWorker(phone);
                      },

                      label: const Text("Call"),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: ElevatedButton(

                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF14b8a6)),

                      onPressed: () {

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PaymentPage(
                              amount: req['amount'],
                              worker_id: req['worker_id'].toString(),
                            ),
                          ),
                        );

                      },

                      child: const Text("Pay Now"),
                    ),
                  ),

                ],
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("My Work Requests"),
        backgroundColor: const Color(0xFF14b8a6),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())

          : requestList.isEmpty
          ? const Center(child: Text("No Requests Found"))

          : ListView.builder(
        itemCount: requestList.length,
        itemBuilder: (context, index) {
          return requestCard(index);
        },
      ),
    );
  }
}