

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class WorkerViewPaymentsPage extends StatefulWidget {
  const WorkerViewPaymentsPage({Key? key}) : super(key: key);

  @override
  State<WorkerViewPaymentsPage> createState() =>
      _WorkerViewPaymentsPageState();
}

class _WorkerViewPaymentsPageState
    extends State<WorkerViewPaymentsPage> {
  List payments = [];
  bool isLoading = true;
  String message = "Loading payments...";

  static const Color bgColor = Color(0xFF0D0D12);
  static const Color cardColor = Color(0xFF17171F);
  static const Color purple = Color(0xFF7C3AED);
  static const Color lightPurple = Color(0xFFA855F7);
  static const Color whiteText = Colors.white;
  static const Color subText = Color(0xFFB8B8C2);

  @override
  void initState() {
    super.initState();
    fetchPayments();
  }

  Future<void> fetchPayments() async {
    setState(() {
      isLoading = true;
      message = "Fetching payments...";
    });

    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String baseUrl = sh.getString('url') ?? "";
      String lid = sh.getString('lid') ?? "";

      if (baseUrl.isEmpty || lid.isEmpty) {
        setState(() {
          message = "URL or Login ID missing";
          isLoading = false;
        });
        return;
      }

      final uri = Uri.parse("$baseUrl/worker_view_payments/");

      final response = await http.post(uri, body: {
        'lid': lid,
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'ok') {
          List temp = data['data'] ?? [];

          setState(() {
            payments = temp;
            isLoading = false;
            message = payments.isEmpty
                ? "No Payments Received Yet"
                : "";
          });
        } else {
          setState(() {
            payments = [];
            message = data['error'] ?? "No Payments Found";
            isLoading = false;
          });
        }
      } else {
        setState(() {
          message = "Server Error: ${response.statusCode}";
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

  Widget paymentCard(int index) {
    final payment = payments[index];

    String userName = payment['user_name']?.toString() ?? "Unknown User";
    String amount = payment['amount']?.toString() ?? "0";
    String status = payment['status']?.toString() ?? "pending";

    return Card(
      color: cardColor,
      elevation: 5,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "User: $userName",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: whiteText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Amount: ₹$amount",
              style: const TextStyle(
                fontSize: 16,
                color: lightPurple, // 👈 themed instead of green
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text(
                  "Status: ",
                  style: TextStyle(
                    fontSize: 16,
                    color: whiteText,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: status.toLowerCase() == "paid"
                        ? purple // 👈 themed green → purple
                        : Colors.orange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
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
      backgroundColor: bgColor,

      appBar: AppBar(
        title: const Text(
          "Payments Received",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: fetchPayments,
          )
        ],
      ),

      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: lightPurple,
        ),
      )
          : payments.isEmpty
          ? Center(
        child: Text(
          message,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: whiteText,
          ),
        ),
      )
          : RefreshIndicator(
        color: lightPurple,
        onRefresh: fetchPayments,
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: payments.length,
          itemBuilder: (context, index) {
            return paymentCard(index);
          },
        ),
      ),
    );
  }
}