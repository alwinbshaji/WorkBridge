import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class SendReviews extends StatefulWidget {
  const SendReviews({super.key});

  @override
  State<SendReviews> createState() => _SendReviewsState();
}

class _SendReviewsState extends State<SendReviews> {
  TextEditingController Review = TextEditingController();
  TextEditingController Rating = TextEditingController();

  Future<void> SendReviews() async {
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
      String url = sp.getString('url') ?? '';
      String lid = sp.getString('lid') ?? '';
      final response = await http.post(
          Uri.parse('$url/send_review/'), body: {
        'lid': lid.toString(),
        'Review': Review.text.toString(),
        'Rating': Rating.text.toString()
      }
      );
      if (response.statusCode != 200) {
        Fluttertoast.showToast(msg: 'Server error');
        return;
      }

      final data = jsonDecode(response.body);

      if (data['status'] == 'ok') {
        Navigator.pop(context);
      } else {
        Fluttertoast.showToast(
          msg: data['message'] ?? '',
        );
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TextFormField(
            controller: Review,
          ),
          TextFormField(
            controller: Rating,
          ),
          ElevatedButton(onPressed: () {
            SendReviews();
          }, child: Text('send_review'))
        ],
      ),
    );
  }
}