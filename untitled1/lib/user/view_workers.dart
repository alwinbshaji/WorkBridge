
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'requestworkpage.dart';
import 'vieweachworkerreview.dart'; // 👈 your review page

class UserViewWorkPage extends StatefulWidget {
  const UserViewWorkPage({super.key});

  @override
  State<UserViewWorkPage> createState() => _UserViewWorkPageState();
}

class _UserViewWorkPageState extends State<UserViewWorkPage> {

  List works = [];
  bool isLoading = true;
  String baseUrl = "";
  String message = "";

  @override
  void initState() {
    super.initState();
    loadWorks();
  }

  Future<void> loadWorks() async {
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
      baseUrl = sp.getString('url') ?? "";

      final response = await http.get(
        Uri.parse("$baseUrl/user_view_work_details/"),
      );

      if (response.statusCode == 200) {

        final data = jsonDecode(response.body);
        print("WORK DATA: $data"); // 🔍 DEBUG

        if (data['status'] == 'ok') {
          setState(() {
            works = data['data'];
            isLoading = false;
          });
        } else {
          setState(() {
            message = data['message'] ?? "No Work Available";
            isLoading = false;
          });
        }

      } else {
        setState(() {
          message = "Server Error";
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

  Widget workCard(dynamic work) {

    String workerId = work['worker_id'].toString(); // ✅ FIXED

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(12),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              "Worker: ${work['worker_name'] ?? 'No Name'}",
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            Text("Job: ${work['job'] ?? 'N/A'}"),
            Text("Amount: ₹${work['amount'] ?? '0'}"),
            Text("Place: ${work['place'] ?? 'N/A'}"),

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [

                /// 🔵 REQUEST BUTTON
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF14b8a6)),
                  onPressed: () {

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RequestWorkPage(
                          workId: work['id'].toString(),
                          job: work['job'] ?? '',
                          workerName: work['worker_name'] ?? '',
                        ),
                      ),
                    );

                  },
                  child: const Text("Request"),
                ),

                /// 🟠 VIEW REVIEWS BUTTON
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange),
                  onPressed: () {

                    print("Worker ID: $workerId"); // 🔍 DEBUG

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => WorkerReviewPage(
                          workerId: workerId,
                          workerName: work['worker_name'] ?? '',
                        ),
                      ),
                    );

                  },
                  child: const Text("View Reviews"),
                ),

              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Available Works"),
        backgroundColor: const Color(0xFF14b8a6),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())

          : works.isEmpty

          ? Center(
        child: Text(
          message.isEmpty ? "No Work Available" : message,
          style: const TextStyle(fontSize: 18),
        ),
      )

          : RefreshIndicator(
        onRefresh: loadWorks,
        child: ListView.builder(
          itemCount: works.length,
          itemBuilder: (context, index) {
            return workCard(works[index]);
          },
        ),
      ),
    );
  }

}