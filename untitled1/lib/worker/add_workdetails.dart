
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WorkerAddWorkPage extends StatefulWidget {
  const WorkerAddWorkPage({super.key});

  @override
  State<WorkerAddWorkPage> createState() => _WorkerAddWorkPageState();
}

class _WorkerAddWorkPageState extends State<WorkerAddWorkPage> {
  TextEditingController jobController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  bool isLoading = false;

  static const Color bgColor = Color(0xFF0D0D12);
  static const Color cardColor = Color(0xFF17171F);
  static const Color purple = Color(0xFF7C3AED);
  static const Color lightPurple = Color(0xFFA855F7);
  static const Color borderColor = Color(0xFF2A2A35);
  static const Color whiteText = Colors.white;
  static const Color subText = Color(0xFFB8B8C2);

  Future<void> addWork() async {
    if (jobController.text.isEmpty || amountController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Enter all fields");
      return;
    }

    setState(() => isLoading = true);

    SharedPreferences sp = await SharedPreferences.getInstance();
    String url = sp.getString('url') ?? "";
    String lid = sp.getString('lid') ?? "";

    final response = await http.post(
      Uri.parse("$url/worker_add_work/"),
      body: {
        'lid': lid,
        'job': jobController.text,
        'amount': amountController.text,
      },
    );

    final data = jsonDecode(response.body);
    setState(() => isLoading = false);

    if (data['status'] == 'ok') {
      Fluttertoast.showToast(msg: "Work Added Successfully");
      jobController.clear();
      amountController.clear();
    } else {
      Fluttertoast.showToast(msg: "Failed to Add Work");
    }
  }

  Widget textField(TextEditingController c, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextField(
        controller: c,
        style: const TextStyle(
          color: whiteText,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: subText),
          filled: true,
          fillColor: cardColor,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: lightPurple, width: 1.5),
          ),
        ),
      ),
    );
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
          Icon(Icons.add_business_rounded, size: 58, color: Colors.white),
          SizedBox(height: 12),
          Text(
            "Add Work Details",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6),
          Text(
            "Enter your job details and pricing",
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text(
          "Add Work Details",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
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
          : SingleChildScrollView(
        child: Column(
          children: [
            buildTopHeader(),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.30),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    textField(jobController, "Job Name"),
                    textField(amountController, "Amount"),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: addWork,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: purple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          "ADD WORK",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}