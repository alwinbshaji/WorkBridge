import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'requestworkpage.dart';

class WorkerWorkDetailsPage extends StatefulWidget {
  final String workerId;
  final String workerName;

  const WorkerWorkDetailsPage({
    Key? key,
    required this.workerId,
    required this.workerName,
  }) : super(key: key);

  @override
  State<WorkerWorkDetailsPage> createState() =>
      _WorkerWorkDetailsPageState();
}

class _WorkerWorkDetailsPageState
    extends State<WorkerWorkDetailsPage> {
  List works = [];
  bool isLoading = true;
  String message = "";

  @override
  void initState() {
    super.initState();
    fetchWorkDetails();
  }

  // 🔥 FETCH WORK DETAILS OF SELECTED WORKER
  Future<void> fetchWorkDetails() async {
    try {
      SharedPreferences sh =
      await SharedPreferences.getInstance();
      String url = sh.getString('url') ?? '';

      final uri =
      Uri.parse('$url/view_worker_work_details/');

      final response = await http.post(uri, body: {
        'worker_id': widget.workerId,
      });

      var data = json.decode(response.body);

      if (data['status'] == 'ok') {
        setState(() {
          works = data['works'];
          isLoading = false;
        });
      } else {
        setState(() {
          message = data['message'] ?? "No works found";
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

  // 🔥 YOUR INSERTED CARD (UPDATED PROPERLY)
  Widget workCard(int index) {
    final work = works[index];

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Worker: ${work['worker_name'] ?? widget.workerName}",
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text("Job: ${work['job'] ?? 'N/A'}"),
            Text("Amount: ₹${work['amount'] ?? '0'}"),
            Text("Place: ${work['place'] ?? 'N/A'}"),
            const SizedBox(height: 12),

            // 🔥 REQUEST BUTTON (NAVIGATION)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF14b8a6),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RequestWorkPage(
                        workId: work['work_id'].toString(),
                        job: work['job'] ?? '',
                        workerName:
                        work['worker_name'] ??
                            widget.workerName,
                      ),
                    ),
                  );
                },
                child: const Text(
                  "Request Work",
                  style: TextStyle(fontSize: 16),
                ),
              ),
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
        title: Text("${widget.workerName} Work Details"),
        backgroundColor: const Color(0xFF14b8a6),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : works.isEmpty
          ? Center(
        child: Text(
          message.isEmpty
              ? "No Work Details Added by Worker"
              : message,
          style: const TextStyle(fontSize: 18),
        ),
      )
          : RefreshIndicator(
        onRefresh: fetchWorkDetails,
        child: ListView.builder(
          itemCount: works.length,
          itemBuilder: (context, index) {
            return workCard(index); // 🔥 INSERTED HERE
          },
        ),
      ),
    );
  }
}