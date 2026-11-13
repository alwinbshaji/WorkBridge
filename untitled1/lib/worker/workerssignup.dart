import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../login.dart';

class WorkerssignupPage extends StatefulWidget {
  const WorkerssignupPage({super.key});

  @override
  State<WorkerssignupPage> createState() => _WorkerssignupPageState();
}

class _WorkerssignupPageState extends State<WorkerssignupPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController placeController = TextEditingController();
  TextEditingController postController = TextEditingController();
  TextEditingController pinController = TextEditingController();
  TextEditingController jobController = TextEditingController();
  TextEditingController experienceController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  List categoryList = [];
  String? selectedCategory;
  File? _image;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String url = sh.getString('url').toString();

    final response = await http.get(Uri.parse('$url/get_categories/'));
    final data = jsonDecode(response.body);

    if (data['status'] == 'ok') {
      setState(() {
        categoryList = data['data'];
      });
    }
  }

  Future<void> pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
      });
    }
  }

  Future<void> registerWorker() async {
    if (!_formKey.currentState!.validate()) return;

    if (_image == null) {
      Fluttertoast.showToast(msg: "Please select photo");
      return;
    }

    if (selectedCategory == null) {
      Fluttertoast.showToast(msg: "Select category");
      return;
    }

    setState(() => _isLoading = true);

    SharedPreferences sh = await SharedPreferences.getInstance();
    String url = sh.getString('url').toString();

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$url/worker_register/'),
    );

    request.fields['name'] = nameController.text;
    request.fields['email'] = emailController.text;
    request.fields['phone'] = phoneController.text;
    request.fields['place'] = placeController.text;
    request.fields['post'] = postController.text;
    request.fields['pin'] = pinController.text;
    request.fields['job'] = jobController.text;
    request.fields['experience'] = experienceController.text;
    request.fields['category'] = selectedCategory!;
    request.fields['password'] = passwordController.text;

    request.files.add(
      await http.MultipartFile.fromPath('photo', _image!.path),
    );

    var response = await request.send();
    var res = await http.Response.fromStream(response);
    final data = jsonDecode(res.body);

    setState(() => _isLoading = false);

    if (data['status'] == 'ok') {
      Fluttertoast.showToast(msg: "Worker Registration Successful");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MyLoginPage(title: "Login"),
        ),
      );
    } else {
      Fluttertoast.showToast(msg: data['message'] ?? "Failed");
    }
  }

  Widget buildTextField(String label, TextEditingController controller,
      IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        validator: (v) =>
        v == null || v.isEmpty ? "$label is required" : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Worker Registration"),
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
                  backgroundImage:
                  _image != null ? FileImage(_image!) : null,
                  child: _image == null
                      ? const Icon(Icons.camera_alt, size: 40)
                      : null,
                ),
              ),

              const SizedBox(height: 20),

              buildTextField("Name", nameController, Icons.person),
              buildTextField("Email", emailController, Icons.email),
              buildTextField("Phone", phoneController, Icons.phone),
              buildTextField("Place", placeController, Icons.location_on),
              buildTextField("Post", postController, Icons.local_post_office),
              buildTextField("PIN", pinController, Icons.pin_drop),
              buildTextField("Job", jobController, Icons.work),
              buildTextField(
                  "Experience (years)", experienceController, Icons.star),

              const SizedBox(height: 10),

              DropdownButtonFormField(
                value: selectedCategory,
                hint: const Text("Select Category"),
                items: categoryList.map<DropdownMenuItem>((item) {
                  return DropdownMenuItem(
                    value: item['id'].toString(),
                    child: Text(item['type']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value.toString();
                  });
                },
                validator: (v) => v == null ? "Select category" : null,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: passwordController,
                obscureText: _obscurePassword,
                validator: (v) =>
                v == null || v.length < 4 ? "Min 4 characters" : null,
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: const Icon(Icons.lock),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : registerWorker,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Register as Worker"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}