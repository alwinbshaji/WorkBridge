

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'edit_workdetails.dart';

class WorkerViewWorkPage extends StatefulWidget {
  const WorkerViewWorkPage({super.key});

  @override
  State<WorkerViewWorkPage> createState() => _WorkerViewWorkPageState();
}

class _WorkerViewWorkPageState extends State<WorkerViewWorkPage> {
  List workList = [];
  bool isLoading = true;

  static const Color bgColor = Color(0xFF0D0D12);
  static const Color cardColor = Color(0xFF17171F);
  static const Color purple = Color(0xFF7C3AED);
  static const Color lightPurple = Color(0xFFA855F7);
  static const Color borderColor = Color(0xFF2A2A35);
  static const Color whiteText = Colors.white;
  static const Color subText = Color(0xFFB8B8C2);

  @override
  void initState() {
    super.initState();
    loadWorks();
  }

  Future<void> loadWorks() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String url = sp.getString('url') ?? "";
    String lid = sp.getString('lid') ?? "";

    final response = await http.post(
      Uri.parse("$url/worker_view_work/"),
      body: {'lid': lid},
    );

    final data = jsonDecode(response.body);

    if (data['status'] == 'ok') {
      setState(() {
        workList = data['data'];
        isLoading = false;
      });
    }
  }

  Future<void> deleteWork(String wid) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String url = sp.getString('url') ?? "";

    final response = await http.post(
      Uri.parse("$url/worker_delete_work/"),
      body: {'wid': wid},
    );

    final data = jsonDecode(response.body);

    if (data['status'] == 'ok') {
      Fluttertoast.showToast(msg: "Deleted Successfully");
      loadWorks();
    } else {
      Fluttertoast.showToast(msg: "Delete Failed");
    }
  }

  Widget buildTopHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF000000), Color(0xFF2E1065), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: const Column(
        children: [
          Icon(Icons.work_outline_rounded, size: 58, color: Colors.white),
          SizedBox(height: 12),
          Text(
            "My Work Details",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6),
          Text(
            "View, edit and manage your work details",
            style: TextStyle(
              color: Color(0xFFE9D5FF),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget buildWorkCard(dynamic work) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.28),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [purple, lightPurple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(
              Icons.handyman_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  work['job'],
                  style: const TextStyle(
                    color: whiteText,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Amount: ₹${work['amount']}",
                  style: const TextStyle(
                    color: subText,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => WorkerEditWorkPage(
                                wid: work['id'].toString(),
                                job: work['job'],
                                amount: work['amount'],
                              ),
                            ),
                          ).then((_) => loadWorks());
                        },
                        icon: const Icon(Icons.edit, color: lightPurple),
                        label: const Text(
                          "Edit",
                          style: TextStyle(color: whiteText),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: borderColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          deleteWork(work['id'].toString());
                        },
                        icon: const Icon(Icons.delete_outline, color: Colors.white),
                        label: const Text(
                          "Delete",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.work_off_outlined,
              size: 70,
              color: Color(0xFFA855F7),
            ),
            SizedBox(height: 14),
            Text(
              "No Work Added",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 6),
            Text(
              "Your added work details will appear here.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: subText,
                fontSize: 14,
              ),
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
          "My Work Details",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: lightPurple,
        ),
      )
          : Column(
        children: [
          buildTopHeader(),
          Expanded(
            child: workList.isEmpty
                ? buildEmptyState()
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: workList.length,
              itemBuilder: (context, index) {
                final work = workList[index];
                return buildWorkCard(work);
              },
            ),
          ),
        ],
      ),
    );
  }
}