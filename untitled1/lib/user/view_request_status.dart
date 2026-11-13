import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

class UserRequestStatusPage extends StatefulWidget {
  const UserRequestStatusPage({super.key});

  @override
  State<UserRequestStatusPage> createState() =>
      _UserRequestStatusPageState();
}

class _UserRequestStatusPageState
    extends State<UserRequestStatusPage> {

  bool isLoading = true;
  List requests = [];

  @override
  void initState() {
    super.initState();
    fetchRequests();
  }

  // 🔹 FETCH REQUEST STATUS
  Future<void> fetchRequests() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String baseUrl = sp.getString('url') ?? '';
    String lid = sp.getString('lid') ?? '';

    var response = await http.post(
      Uri.parse('$baseUrl/view_request_status/'),
      body: {"lid": lid},
    );

    var data = jsonDecode(response.body);

    if (data['status'] == 'ok') {
      setState(() {
        requests = data['data'];
        isLoading = false;
      });
    } else {
      Fluttertoast.showToast(msg: "No requests found");
      setState(() => isLoading = false);
    }
  }

  // 🔹 STATUS COLOR
  Color getStatusColor(String status) {
    if (status == "Approved") {
      return Colors.green;
    } else if (status == "Rejected") {
      return Colors.red;
    } else {
      return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Work Requests"),
        backgroundColor: Colors.teal,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : requests.isEmpty
          ? const Center(child: Text("No Requests Found"))
          : ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: requests.length,
        itemBuilder: (context, index) {
          var item = requests[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 15),
            elevation: 4,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [

                  Text(
                    item['worker_name'],
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  Text("Job: ${item['job']}"),
                  Text("Amount: ₹${item['amount']}"),
                  Text("Date: ${item['date']}"),

                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: getStatusColor(
                          item['work_status'])
                          .withOpacity(0.2),
                      borderRadius:
                      BorderRadius.circular(20),
                    ),
                    child: Text(
                      item['work_status'],
                      style: TextStyle(
                        color: getStatusColor(
                            item['work_status']),
                        fontWeight: FontWeight.bold,
                      ),
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