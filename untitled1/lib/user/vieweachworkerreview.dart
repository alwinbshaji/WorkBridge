import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class WorkerReviewPage extends StatefulWidget {

  final String workerId;
  final String workerName;

  const WorkerReviewPage({
    super.key,
    required this.workerId,
    required this.workerName
  });

  @override
  State<WorkerReviewPage> createState() => _WorkerReviewPageState();
}

class _WorkerReviewPageState extends State<WorkerReviewPage> {

  List reviewList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadReviews();
  }

  Future<void> loadReviews() async {

    SharedPreferences sp = await SharedPreferences.getInstance();
    String url = sp.getString('url') ?? "";
    String lid = sp.getString('lid') ?? "";

    final response = await http.post(
      Uri.parse("$url/view_worker_reviews/"),
      body: {
        "worker_id": widget.workerId,
        "lid": lid
      },
    );

    final data = jsonDecode(response.body);

    if (data['status'] == "ok") {

      setState(() {
        reviewList = data['data'];
        isLoading = false;
      });

    } else {

      setState(() {
        reviewList = [];
        isLoading = false;
      });
    }
  }

  Widget reviewCard(int index){

    final item = reviewList[index];

    return Card(

      margin: const EdgeInsets.all(10),
      elevation: 3,

      child: Padding(
        padding: const EdgeInsets.all(12),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Text(
              item['username'],
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),

            const SizedBox(height:5),

            Row(
              children: [
                const Icon(Icons.star,color: Colors.orange),
                Text(item['rating'])
              ],
            ),

            const SizedBox(height:5),

            Text(item['review']),

            const SizedBox(height:5),

            Text(
              item['date'],
              style: const TextStyle(color: Colors.grey),
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
        title: Text("${widget.workerName} Reviews"),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())

          : reviewList.isEmpty
          ? const Center(child: Text("No Reviews Yet"))

          : ListView.builder(
        itemCount: reviewList.length,
        itemBuilder: (context,index){
          return reviewCard(index);
        },
      ),
    );
  }
}