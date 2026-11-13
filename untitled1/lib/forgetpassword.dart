

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {

  final emailController = TextEditingController();
  final otpController = TextEditingController();
  final passwordController = TextEditingController();

  bool otpSent = false;

  // 🎨 COLORS
  static const Color bgColor = Color(0xFF0D0D12);
  static const Color cardColor = Color(0xFF17171F);
  static const Color accent = Color(0xFF6D28D9);
  static const Color textWhite = Colors.white;
  static const Color textGrey = Color(0xFFB8B8C2);

  // 🔥 SEND OTP
  Future<void> sendOTP() async {

    SharedPreferences sp = await SharedPreferences.getInstance();
    String url = sp.getString('url') ?? '';

    final response = await http.post(
        Uri.parse('$url/send_forgot_otp/'),
        body: {
          'email': emailController.text
        }
    );

    var data = jsonDecode(response.body);

    if(data['status'] == 'ok'){
      setState(() {
        otpSent = true;
      });

      Fluttertoast.showToast(msg: "OTP sent to email");
    }
    else{
      Fluttertoast.showToast(msg: data['message']);
    }

  }


  // 🔥 RESET PASSWORD
  Future<void> resetPassword() async {

    SharedPreferences sp = await SharedPreferences.getInstance();
    String url = sp.getString('url') ?? '';

    final response = await http.post(
        Uri.parse('$url/reset_password/'),
        body: {
          'email': emailController.text,
          'otp': otpController.text,
          'password': passwordController.text
        }
    );

    var data = jsonDecode(response.body);

    if(data['status']=='ok'){
      Fluttertoast.showToast(msg: "Password Reset Successful");

      Navigator.pop(context);
    }
    else{
      Fluttertoast.showToast(msg: "Invalid OTP");
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: bgColor,

      appBar: AppBar(
        title: const Text(
          "Forgot Password",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(

          children: [

            TextField(
              controller: emailController,
              style: const TextStyle(color: textWhite),
              decoration: InputDecoration(
                labelText: "Email",
                labelStyle: const TextStyle(color: textGrey),
                filled: true,
                fillColor: cardColor,
                prefixIcon: const Icon(Icons.email, color: accent),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const SizedBox(height:20),

            if(!otpSent)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: sendOTP,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                  ),
                  child: const Text("Send OTP"),
                ),
              ),

            if(otpSent)...[

              TextField(
                controller: otpController,
                style: const TextStyle(color: textWhite),
                decoration: InputDecoration(
                  labelText: "Enter OTP",
                  labelStyle: const TextStyle(color: textGrey),
                  filled: true,
                  fillColor: cardColor,
                  prefixIcon: const Icon(Icons.security, color: accent),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),

              const SizedBox(height:20),

              TextField(
                controller: passwordController,
                style: const TextStyle(color: textWhite),
                decoration: InputDecoration(
                  labelText: "New Password",
                  labelStyle: const TextStyle(color: textGrey),
                  filled: true,
                  fillColor: cardColor,
                  prefixIcon: const Icon(Icons.lock, color: accent),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),

              const SizedBox(height:20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: resetPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                  ),
                  child: const Text("Reset Password"),
                ),
              ),

            ]

          ],
        ),
      ),
    );
  }
}