import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ViewPaymentHistoryPage extends StatefulWidget {
  const ViewPaymentHistoryPage({super.key});

  @override
  State<ViewPaymentHistoryPage> createState() =>
      _ViewPaymentHistoryPageState();
}

class _ViewPaymentHistoryPageState extends State<ViewPaymentHistoryPage> {
  List paymentList = [];
  bool isLoading = true;
  String baseUrl = "";

  @override
  void initState() {
    super.initState();
    loadPaymentHistory();
  }

  Future<void> loadPaymentHistory() async {
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
      baseUrl = sp.getString('url') ?? "";
      String lid = sp.getString('lid') ?? "";

      final response = await http.post(
        Uri.parse("$baseUrl/user_view_payment_history/"),
        body: {'lid': lid},
      );

      final data = jsonDecode(response.body);

      if (data['status'] == 'ok') {
        setState(() {
          paymentList = data['data'];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Color getStatusColor(String status) {
    if (status.toLowerCase() == "paid") {
      return Colors.green;
    } else if (status.toLowerCase() == "pending") {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  Widget paymentCard(int index) {
    final payment = paymentList[index];

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Worker: ${payment['worker_name']}",
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              "Amount: ₹${payment['amount']}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 6),

            Row(
              children: [
                const Text(
                  "Status: ",
                  style: TextStyle(fontSize: 16),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: getStatusColor(payment['status']),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    payment['status'].toUpperCase(),
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
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
        title: const Text("Payment History"),
        backgroundColor: const Color(0xFF14b8a6),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : paymentList.isEmpty
          ? const Center(
        child: Text(
          "No Payment History Found",
          style: TextStyle(fontSize: 16),
        ),
      )
          : RefreshIndicator(
        onRefresh: loadPaymentHistory,
        child: ListView.builder(
          itemCount: paymentList.length,
          itemBuilder: (context, index) {
            return paymentCard(index);
          },
        ),
      ),
    );
  }
}