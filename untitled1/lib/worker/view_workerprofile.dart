

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'edit_workerprofile.dart';

class WorkerProfilePage extends StatefulWidget {
  const WorkerProfilePage({super.key});

  @override
  State<WorkerProfilePage> createState() => _WorkerProfilePageState();
}

class _WorkerProfilePageState extends State<WorkerProfilePage> {
  bool isLoading = true;

  String name = '';
  String photo = '';
  String phone = '';
  String email = '';
  String place = '';
  String post = '';
  String pin = '';
  String job = '';
  String experience = '';
  String category = '';
  String statusWorker = '';
  String serverUrl = '';

  // 🔥 THEME COLORS (added only)
  static const Color bgColor = Color(0xFF0D0D12);
  static const Color cardColor = Color(0xFF17171F);
  static const Color purple = Color(0xFF7C3AED);
  static const Color lightPurple = Color(0xFFA855F7);
  static const Color whiteText = Colors.white;
  static const Color subText = Color(0xFFB8B8C2);

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String url = sp.getString('url') ?? '';
    String lid = sp.getString('lid') ?? '';

    serverUrl = url;
    if (!serverUrl.endsWith("/")) {
      serverUrl = "$serverUrl/";
    }

    final response = await http.post(
      Uri.parse(serverUrl + "worker_view_profile/"),
      body: {'lid': lid},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['status'] == 'ok') {

        String imagePath = data['photo']?.toString() ?? "";
        String finalPhotoUrl = "";

        if (imagePath.isNotEmpty) {
          if (imagePath.startsWith("/media/")) {
            String serverBase = serverUrl.replaceAll("myapp/", "");
            finalPhotoUrl = serverBase + imagePath;
          } else {
            finalPhotoUrl = serverUrl + imagePath;
          }
        }

        setState(() {
          name = data['name']?.toString() ?? '';
          photo = finalPhotoUrl;
          phone = data['phone']?.toString() ?? '';
          email = data['email']?.toString() ?? '';
          place = data['place']?.toString() ?? '';
          post = data['post']?.toString() ?? '';
          pin = data['pin']?.toString() ?? '';
          job = data['job']?.toString() ?? '';
          experience = data['experience']?.toString() ?? '';
          category = data['category']?.toString() ?? '';
          statusWorker = data['status_worker']?.toString() ?? '';
          isLoading = false;
        });

        print("Final Worker Image URL: $photo");
      }
    }
  }

  Widget profileTile(IconData icon, String title, String value) {
    return Card(
      color: cardColor, // ✅ changed
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: lightPurple), // ✅ changed
        title: Text(
          title,
          style: const TextStyle(color: whiteText), // ✅ changed
        ),
        subtitle: Text(
          value.isEmpty ? "Not Available" : value,
          style: const TextStyle(color: subText), // ✅ changed
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor, // ✅ changed

      appBar: AppBar(
        title: const Text(
          "Worker Profile",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black, // ✅ changed
        iconTheme: const IconThemeData(color: Colors.white), // ✅
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white), // ✅
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WorkerEditProfilePage(),
                ),
              );
              loadProfile();
            },
          )
        ],
      ),

      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: lightPurple, // ✅ changed
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),

            CircleAvatar(
              radius: 70,
              backgroundColor: cardColor, // ✅ changed
              backgroundImage:
              photo.isNotEmpty ? NetworkImage(photo) : null,
              child: photo.isEmpty
                  ? const Icon(Icons.person,
                  size: 60, color: subText) // ✅ changed
                  : null,
            ),

            const SizedBox(height: 20),

            Text(
              name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: whiteText, // ✅ changed
              ),
            ),

            const SizedBox(height: 20),

            profileTile(Icons.email, "Email", email),
            profileTile(Icons.phone, "Phone", phone),
            profileTile(Icons.work, "Job", job),
            profileTile(Icons.category, "Category", category),
            profileTile(Icons.star, "Experience", experience),
            profileTile(Icons.location_city, "Place", place),
            profileTile(Icons.local_post_office, "Post", post),
            profileTile(Icons.pin_drop, "Pin", pin),
          ],
        ),
      ),
    );
  }
}