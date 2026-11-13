

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RequestWorkPage extends StatefulWidget {
  final String workId;
  final String job;
  final String workerName;

  const RequestWorkPage({
    super.key,
    required this.workId,
    required this.job,
    required this.workerName,
  });

  @override
  State<RequestWorkPage> createState() => _RequestWorkPageState();
}

class _RequestWorkPageState extends State<RequestWorkPage> {

  TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController placeController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  bool isLoading = false;

  // DATE PICKER
  Future<void> selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
    );

    if (picked != null) {
      dateController.text =
      "${picked.year}-${picked.month}-${picked.day}";
    }
  }

  // TIME PICKER
  Future<void> selectTime() async {

    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {

      // Convert to Django TimeField format HH:mm:ss
      String hour = picked.hour.toString().padLeft(2, '0');
      String minute = picked.minute.toString().padLeft(2, '0');

      timeController.text = "$hour:$minute:00";
    }
  }

  // SEND REQUEST
  Future<void> sendRequest() async {

    if (dateController.text.isEmpty ||
        timeController.text.isEmpty ||
        placeController.text.isEmpty ||
        descriptionController.text.isEmpty) {

      Fluttertoast.showToast(msg: "Please fill all fields");
      return;
    }

    setState(() {
      isLoading = true;
    });

    SharedPreferences sp = await SharedPreferences.getInstance();

    String url = sp.getString('url') ?? "";
    String lid = sp.getString('lid') ?? "";

    var response = await http.post(
      Uri.parse("$url/send_work_request/"),
      body: {
        'lid': lid,
        'work_id': widget.workId,
        'date': dateController.text,
        'worktime': timeController.text,
        'place': placeController.text,
        'description': descriptionController.text,
      },
    );

    print(response.body); // for debugging

    var data = jsonDecode(response.body);

    setState(() {
      isLoading = false;
    });

    if (data['status'] == 'ok') {
      Fluttertoast.showToast(msg: "Request Sent Successfully");
      Navigator.pop(context);

    } else if (data['status'] == 'already') {
      Fluttertoast.showToast(msg: "Already Requested");

    } else {
      Fluttertoast.showToast(msg: "Request Failed");
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Request Work"),
        backgroundColor: const Color(0xFF14b8a6),
      ),

      body: SingleChildScrollView(

        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            children: [

              // JOB CARD
              Card(
                elevation: 4,
                child: ListTile(
                  title: Text(
                    widget.job,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                  subtitle: Text("Worker: ${widget.workerName}"),
                ),
              ),

              const SizedBox(height: 25),

              // DATE
              TextField(
                controller: dateController,
                readOnly: true,
                onTap: selectDate,
                decoration: InputDecoration(
                  labelText: "Work Date",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  suffixIcon: const Icon(Icons.calendar_today),
                ),
              ),

              const SizedBox(height: 15),

              // TIME
              TextField(
                controller: timeController,
                readOnly: true,
                onTap: selectTime,
                decoration: InputDecoration(
                  labelText: "Work Time",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  suffixIcon: const Icon(Icons.access_time),
                ),
              ),

              const SizedBox(height: 15),

              // PLACE
              TextField(
                controller: placeController,
                decoration: InputDecoration(
                  labelText: "Work Place",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),

              const SizedBox(height: 15),

              // DESCRIPTION
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: "Work Description",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),

              const SizedBox(height: 30),

              // BUTTON
              SizedBox(
                width: double.infinity,
                height: 50,

                child: ElevatedButton(

                  onPressed: isLoading ? null : sendRequest,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF14b8a6),
                  ),

                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    "CONFIRM REQUEST",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}