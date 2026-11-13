

import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'otp_page.dart';

class MyMySignup extends StatefulWidget {
  const MyMySignup({super.key});

  @override
  State<MyMySignup> createState() => _MyMySignupState();
}

class _MyMySignupState extends State<MyMySignup> {

  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController placeController = TextEditingController();
  final TextEditingController pinController = TextEditingController();
  final TextEditingController postController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage() async {

    final XFile? pickedFile =
    await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> registerUser() async {

    if (!_formKey.currentState!.validate()) return;

    if (_image == null) {
      Fluttertoast.showToast(msg: "Select profile image");
      return;
    }

    setState(() => _loading = true);

    SharedPreferences sp = await SharedPreferences.getInstance();
    String url = sp.getString('url') ?? '';

    var response = await http.post(
      Uri.parse("$url/send_otp/"),
      body: {
        'email': emailController.text.trim()
      },
    );

    setState(() => _loading = false);

    var data = json.decode(response.body);

    if (data['status'] == 'ok') {

      Fluttertoast.showToast(msg: "OTP sent to email");

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OTPPage(
            name: nameController.text,
            phone: phoneController.text,
            email: emailController.text,
            place: placeController.text,
            pin: pinController.text,
            post: postController.text,
            password: passwordController.text,
            image: _image!,
          ),
        ),
      );

    } else {

      Fluttertoast.showToast(msg: data['message']);

    }
  }

  Widget buildTextField(
      String label, TextEditingController controller, IconData icon,
      {bool isPassword = false}) {

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        validator: (value) {

          if (value == null || value.isEmpty) {
            return "$label is required";
          }

          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("User Registration"),
        backgroundColor: Colors.teal,
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(20),

        child: Form(

          key: _formKey,

          child: Column(

            children: [

              GestureDetector(
                onTap: pickImage,
                child: CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: _image != null ? FileImage(_image!) : null,
                  child: _image == null
                      ? const Icon(Icons.camera_alt, size: 40)
                      : null,
                ),
              ),

              const SizedBox(height: 25),

              buildTextField("Name", nameController, Icons.person),
              buildTextField("Phone", phoneController, Icons.phone),
              buildTextField("Email", emailController, Icons.email),
              buildTextField("Place", placeController, Icons.location_city),
              buildTextField("Post", postController, Icons.local_post_office),
              buildTextField("Pin", pinController, Icons.pin_drop),
              buildTextField(
                  "Password", passwordController, Icons.lock,
                  isPassword: true),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(

                  onPressed: _loading ? null : registerUser,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                  ),

                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("REGISTER",
                      style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}