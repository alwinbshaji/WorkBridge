

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import 'user/usersignup.dart';
import 'worker/workerssignup.dart';
import 'user/userhome.dart';
import 'worker/workershome.dart';
import 'forgetpassword.dart';

class MyLoginPage extends StatefulWidget {
  const MyLoginPage({super.key, required this.title});
  final String title;

  @override
  State<MyLoginPage> createState() => _MyLoginPageState();
}

class _MyLoginPageState extends State<MyLoginPage> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // 🎨 COLORS (BLACK THEME)
  static const Color bgColor = Color(0xFF0D0D12);
  static const Color cardColor = Color(0xFF17171F);
  static const Color accent = Color(0xFF6D28D9); // purple accent
  static const Color textWhite = Colors.white;
  static const Color textGrey = Color(0xFFB8B8C2);

  Future<void> login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
      String url = sp.getString('url') ?? '';

      if (url.isEmpty) {
        Fluttertoast.showToast(msg: 'Server URL not set');
        setState(() => _loading = false);
        return;
      }

      final response = await http.post(
        Uri.parse('$url/user_login/'),
        body: {
          'email': usernameController.text.trim(),
          'password': passwordController.text.trim(),
        },
      );

      final data = jsonDecode(response.body);

      setState(() => _loading = false);

      if (data['status'] == 'ok') {
        String type = data['type'];
        String lid = data['lid'].toString();

        await sp.setString('lid', lid);

        await updateLoc(lid);

        if (type == 'users') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const UserHomePage()),
          );
        } else if (type == 'workers') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const WorkerHomePage()),
          );
        }
      } else {
        Fluttertoast.showToast(msg: "Invalid Login");
      }
    } catch (e) {
      setState(() => _loading = false);
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  Future<void> updateLoc(String lid) async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      PermissionStatus permission = await Permission.location.request();
      if (!permission.isGranted) return;

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      String lat = position.latitude.toString();
      String lon = position.longitude.toString();

      await sh.setString('lat', lat);
      await sh.setString('lon', lon);

      String url = sh.getString('url') ?? '';

      await http.post(
        Uri.parse('$url/updatelocation/'),
        body: {
          'lid': lid,
          'lat': lat,
          'lon': lon,
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor, // 🔥 black background
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 60),

                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: textWhite,
                    ),
                  ),

                  const SizedBox(height: 40),

                  TextFormField(
                    controller: usernameController,
                    style: const TextStyle(color: textWhite),
                    decoration: InputDecoration(
                      labelText: "Email",
                      labelStyle: const TextStyle(color: textGrey),
                      prefixIcon: const Icon(Icons.email, color: accent),
                      filled: true,
                      fillColor: cardColor,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (value) =>
                    value!.isEmpty ? "Enter Email" : null,
                  ),

                  const SizedBox(height: 20),

                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    style: const TextStyle(color: textWhite),
                    decoration: InputDecoration(
                      labelText: "Password",
                      labelStyle: const TextStyle(color: textGrey),
                      prefixIcon: const Icon(Icons.lock, color: accent),
                      filled: true,
                      fillColor: cardColor,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (value) =>
                    value!.length < 4 ? "Minimum 4 characters" : null,
                  ),

                  const SizedBox(height: 5),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      child: const Text(
                        "Forgot Password?",
                        style: TextStyle(color: accent),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ForgotPasswordPage(),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 15),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _loading ? null : login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                      ),
                      child: _loading
                          ? const CircularProgressIndicator(
                          color: Colors.white)
                          : const Text(
                        "LOGIN",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    "Don't have an account?",
                    style: TextStyle(
                      fontSize: 16,
                      color: textGrey,
                    ),
                  ),

                  const SizedBox(height: 15),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: accent),
                        foregroundColor: textWhite,
                      ),
                      child: const Text("Create User Account"),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MyMySignup(),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: accent),
                        foregroundColor: textWhite,
                      ),
                      child: const Text("Register as Worker"),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const WorkerssignupPage(),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}