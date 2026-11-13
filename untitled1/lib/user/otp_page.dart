import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OTPPage extends StatefulWidget {

  final String name;
  final String phone;
  final String email;
  final String place;
  final String pin;
  final String post;
  final String password;
  final File image;

  const OTPPage({
    super.key,
    required this.name,
    required this.phone,
    required this.email,
    required this.place,
    required this.pin,
    required this.post,
    required this.password,
    required this.image,
  });

  @override
  State<OTPPage> createState() => _OTPPageState();
}

class _OTPPageState extends State<OTPPage> {

  TextEditingController otpController = TextEditingController();
  bool loading = false;

  Future<void> verifyOTP() async {

    setState(() => loading = true);

    SharedPreferences sp = await SharedPreferences.getInstance();
    String url = sp.getString('url') ?? '';

    var request = http.MultipartRequest(
      'POST',
      Uri.parse("$url/verify_otp_register/"),
    );

    request.fields['name'] = widget.name;
    request.fields['phone'] = widget.phone;
    request.fields['email'] = widget.email;
    request.fields['place'] = widget.place;
    request.fields['pin'] = widget.pin;
    request.fields['post'] = widget.post;
    request.fields['password'] = widget.password;
    request.fields['otp'] = otpController.text;

    request.files.add(await http.MultipartFile.fromPath(
      'photo',
      widget.image.path,
    ));

    var response = await request.send();
    var res = await http.Response.fromStream(response);

    setState(() => loading = false);

    var data = json.decode(res.body);

    if (data['status'] == 'ok') {

      Fluttertoast.showToast(msg: "Registration Successful");

      Navigator.popUntil(context, (route) => route.isFirst);

    } else {

      Fluttertoast.showToast(msg: data['message']);

    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Verify OTP"),
        backgroundColor: Colors.teal,
      ),

      body: Padding(

        padding: const EdgeInsets.all(20),

        child: Column(

          children: [

            Text(
              "Enter OTP sent to ${widget.email}",
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 30),

            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Enter OTP",
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(

                onPressed: loading ? null : verifyOTP,

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                ),

                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("VERIFY OTP"),
              ),
            )
          ],
        ),
      ),
    );
  }
}