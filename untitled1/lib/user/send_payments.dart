import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class SendPayment extends StatefulWidget {
  const SendPayment({super.key});

  @override
  State<SendPayment> createState() => _SendPaymentState();
}

class _SendPaymentState extends State<SendPayment> {
  TextEditingController payment= TextEditingController();

  Future<void> SendPayment() async {
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
      String url = sp.getString('url') ?? '';
      String lid = sp.getString('lid') ?? '';
      final response = await http.post(
          Uri.parse('$url/send_Workrequest/'), body: {
        'lid': lid.toString(),
        'payment': payment.text.toString()
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
            controller: payment,
          ),
          ElevatedButton(onPressed: (){
            SendPayment();
          }, child: Text('send_payment'))
        ],
      ),
    );
  }
}
