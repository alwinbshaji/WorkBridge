

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ViewNotificationPage extends StatefulWidget {
  const ViewNotificationPage({super.key});

  @override
  State<ViewNotificationPage> createState() => _ViewNotificationPageState();
}

class _ViewNotificationPageState extends State<ViewNotificationPage> {
  List notifications = [];
  bool isLoading = true;

  // 🎨 THEME COLORS
  static const Color bgColor = Color(0xFF0D0D12);
  static const Color cardColor = Color(0xFF17171F);
  static const Color accent = Color(0xFF6366F1); // bluish-purple
  static const Color whiteText = Colors.white;
  static const Color subText = Color(0xFFB8B8C2);

  Future<void> fetchNotifications() async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String url = sh.getString('url') ?? "";

      if (!url.endsWith("/")) {
        url = "$url/";
      }

      final response = await http.get(
        Uri.parse(url + "view_notificationflutter/"),
      );

      final jsonData = json.decode(response.body);

      if (jsonData['status'] == "ok") {
        setState(() {
          notifications = jsonData['data'];
          isLoading = false;
        });
      } else {
        setState(() {
          notifications = [];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        notifications = [];
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to load notifications"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,

      appBar: AppBar(
        title: const Text(
          "Notifications",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: accent,
        ),
      )
          : notifications.isEmpty
          ? const Center(
        child: Text(
          "No Notifications",
          style: TextStyle(
            color: whiteText,
            fontSize: 16,
          ),
        ),
      )
          : ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          return Card(
            color: cardColor,
            margin: const EdgeInsets.all(10),
            child: ListTile(
              leading: const Icon(
                Icons.notifications,
                color: accent,
              ),
              title: Text(
                notifications[index]['message'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: whiteText,
                ),
              ),
              subtitle: Text(
                notifications[index]['date'],
                style: const TextStyle(
                  color: subText,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}