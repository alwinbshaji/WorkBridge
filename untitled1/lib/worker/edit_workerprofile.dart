// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:http/http.dart' as http;
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class WorkerEditProfilePage extends StatefulWidget {
//   const WorkerEditProfilePage({super.key});
//
//   @override
//   State<WorkerEditProfilePage> createState() =>
//       _WorkerEditProfilePageState();
// }
//
// class _WorkerEditProfilePageState extends State<WorkerEditProfilePage> {
//   final _formKey = GlobalKey<FormState>();
//   bool isLoading = false;
//
//   TextEditingController nameController = TextEditingController();
//   TextEditingController phoneController = TextEditingController();
//   TextEditingController placeController = TextEditingController();
//   TextEditingController postController = TextEditingController();
//   TextEditingController pinController = TextEditingController();
//   TextEditingController jobController = TextEditingController();
//   TextEditingController expController = TextEditingController();
//
//   File? _image;
//   final picker = ImagePicker();
//
//   List categories = [];
//   String? selectedCategory;
//   String serverUrl = "";
//   String currentPhoto = ""; // 🔥 store existing photo
//
//   @override
//   void initState() {
//     super.initState();
//     loadCategories();
//     loadProfile();
//   }
//
//   Future<void> loadCategories() async {
//     SharedPreferences sp = await SharedPreferences.getInstance();
//     String url = sp.getString('url') ?? '';
//     serverUrl = url;
//
//     final response =
//     await http.get(Uri.parse('$url/get_categories/'));
//
//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       setState(() {
//         categories = data['data'];
//       });
//     }
//   }
//
//   Future<void> loadProfile() async {
//     SharedPreferences sp = await SharedPreferences.getInstance();
//     String url = sp.getString('url') ?? '';
//     String lid = sp.getString('lid') ?? '';
//
//     // ensure slash
//     if (!url.endsWith("/")) {
//       url = "$url/";
//     }
//     serverUrl = url;
//
//     final response = await http.post(
//       Uri.parse('${url}worker_view_profile/'),
//       body: {'lid': lid},
//     );
//
//     final data = jsonDecode(response.body);
//
//     if (data['status'] == 'ok') {
//       // 🔥 FIX IMAGE URL (same logic as profile page)
//       String imagePath = data['photo'].toString();
//       String finalPhoto = "";
//
//       if (imagePath.isNotEmpty) {
//         if (imagePath.startsWith("/media/")) {
//           String serverBase = url.replaceAll("myapp/", "");
//           finalPhoto = serverBase + imagePath;
//         } else {
//           finalPhoto = url + imagePath;
//         }
//       }
//
//       setState(() {
//         nameController.text = data['name'];
//         phoneController.text = data['phone'];
//         placeController.text = data['place'];
//         postController.text = data['post'];
//         pinController.text = data['pin'];
//         jobController.text = data['job'];
//         expController.text = data['experience'];
//         currentPhoto = finalPhoto; // 🔥 show existing image
//         selectedCategory = data['category_id']?.toString(); // 🔥 default category
//       });
//     }
//   }
//
//   Future<void> pickImage() async {
//     final picked =
//     await picker.pickImage(source: ImageSource.gallery);
//     if (picked != null) {
//       setState(() {
//         _image = File(picked.path);
//       });
//     }
//   }
//
//   Future<void> updateProfile() async {
//     if (!_formKey.currentState!.validate()) return;
//
//     setState(() => isLoading = true);
//
//     SharedPreferences sp = await SharedPreferences.getInstance();
//     String url = sp.getString('url') ?? '';
//     String lid = sp.getString('lid') ?? '';
//
//     var request = http.MultipartRequest(
//       'POST',
//       Uri.parse('$url/worker_edit_profile/'),
//     );
//
//     request.fields['lid'] = lid;
//     request.fields['name'] = nameController.text;
//     request.fields['phone'] = phoneController.text;
//     request.fields['place'] = placeController.text;
//     request.fields['post'] = postController.text;
//     request.fields['pin'] = pinController.text;
//     request.fields['job'] = jobController.text;
//     request.fields['experience'] = expController.text;
//     request.fields['category'] = selectedCategory ?? '';
//
//     if (_image != null) {
//       request.files.add(
//         await http.MultipartFile.fromPath('photo', _image!.path),
//       );
//     }
//
//     var response = await request.send();
//     var res = await http.Response.fromStream(response);
//     final data = jsonDecode(res.body);
//
//     setState(() => isLoading = false);
//
//     if (data['status'] == 'ok') {
//       Fluttertoast.showToast(msg: "Profile Updated Successfully");
//       Navigator.pop(context);
//     } else {
//       Fluttertoast.showToast(msg: "Update Failed");
//     }
//   }
//
//   Widget textField(TextEditingController c, String label) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 15),
//       child: TextFormField(
//         controller: c,
//         validator: (v) =>
//         v == null || v.isEmpty ? 'Enter $label' : null,
//         decoration: InputDecoration(
//           labelText: label,
//           border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12)),
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     ImageProvider? imageProvider;
//
//     // 🔥 SHOW SELECTED IMAGE OR EXISTING IMAGE
//     if (_image != null) {
//       imageProvider = FileImage(_image!);
//     } else if (currentPhoto.isNotEmpty) {
//       imageProvider = NetworkImage(currentPhoto);
//     }
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Edit Profile"),
//         backgroundColor: const Color(0xFF14b8a6),
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               GestureDetector(
//                 onTap: pickImage,
//                 child: CircleAvatar(
//                   radius: 60,
//                   backgroundColor: Colors.grey.shade300,
//                   backgroundImage: imageProvider,
//                   child: imageProvider == null
//                       ? const Icon(Icons.camera_alt, size: 40)
//                       : null,
//                 ),
//               ),
//               const SizedBox(height: 20),
//               textField(nameController, "Name"),
//               textField(phoneController, "Phone"),
//               textField(placeController, "Place"),
//               textField(postController, "Post"),
//               textField(pinController, "Pin"),
//               textField(jobController, "Job"),
//               textField(expController, "Experience"),
//
//               // 🔥 CATEGORY WITH DEFAULT VALUE
//               DropdownButtonFormField(
//                 value: selectedCategory,
//                 hint: const Text("Select Category"),
//                 items: categories.map<DropdownMenuItem>((cat) {
//                   return DropdownMenuItem(
//                     value: cat['id'].toString(),
//                     child: Text(cat['type']),
//                   );
//                 }).toList(),
//                 onChanged: (val) {
//                   setState(() {
//                     selectedCategory = val.toString();
//                   });
//                 },
//                 decoration: InputDecoration(
//                   border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12)),
//                 ),
//               ),
//
//               const SizedBox(height: 25),
//
//               SizedBox(
//                 width: double.infinity,
//                 height: 50,
//                 child: ElevatedButton(
//                   onPressed: updateProfile,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF14b8a6),
//                   ),
//                   child: const Text(
//                     "UPDATE PROFILE",
//                     style: TextStyle(fontSize: 16),
//                   ),
//                 ),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WorkerEditProfilePage extends StatefulWidget {
  const WorkerEditProfilePage({super.key});

  @override
  State<WorkerEditProfilePage> createState() =>
      _WorkerEditProfilePageState();
}

class _WorkerEditProfilePageState extends State<WorkerEditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController placeController = TextEditingController();
  TextEditingController postController = TextEditingController();
  TextEditingController pinController = TextEditingController();
  TextEditingController jobController = TextEditingController();
  TextEditingController expController = TextEditingController();

  File? _image;
  final picker = ImagePicker();

  List categories = [];
  String? selectedCategory;
  String serverUrl = "";
  String currentPhoto = "";

  static const Color bgColor = Color(0xFF0D0D12);
  static const Color cardColor = Color(0xFF17171F);
  static const Color purple = Color(0xFF7C3AED);
  static const Color lightPurple = Color(0xFFA855F7);
  static const Color whiteText = Colors.white;
  static const Color subText = Color(0xFFB8B8C2);
  static const Color borderColor = Color(0xFF2A2A35);

  @override
  void initState() {
    super.initState();
    loadCategories();
    loadProfile();
  }

  Future<void> loadCategories() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String url = sp.getString('url') ?? '';
    serverUrl = url;

    final response =
    await http.get(Uri.parse('$url/get_categories/'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        categories = data['data'];
      });
    }
  }

  Future<void> loadProfile() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String url = sp.getString('url') ?? '';
    String lid = sp.getString('lid') ?? '';

    if (!url.endsWith("/")) {
      url = "$url/";
    }
    serverUrl = url;

    final response = await http.post(
      Uri.parse('${url}worker_view_profile/'),
      body: {'lid': lid},
    );

    final data = jsonDecode(response.body);

    if (data['status'] == 'ok') {
      String imagePath = data['photo'].toString();
      String finalPhoto = "";

      if (imagePath.isNotEmpty) {
        if (imagePath.startsWith("/media/")) {
          String serverBase = url.replaceAll("myapp/", "");
          finalPhoto = serverBase + imagePath;
        } else {
          finalPhoto = url + imagePath;
        }
      }

      setState(() {
        nameController.text = data['name'];
        phoneController.text = data['phone'];
        placeController.text = data['place'];
        postController.text = data['post'];
        pinController.text = data['pin'];
        jobController.text = data['job'];
        expController.text = data['experience'];
        currentPhoto = finalPhoto;
        selectedCategory = data['category_id']?.toString();
      });
    }
  }

  Future<void> pickImage() async {
    final picked =
    await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
      });
    }
  }

  Future<void> updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    SharedPreferences sp = await SharedPreferences.getInstance();
    String url = sp.getString('url') ?? '';
    String lid = sp.getString('lid') ?? '';

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$url/worker_edit_profile/'),
    );

    request.fields['lid'] = lid;
    request.fields['name'] = nameController.text;
    request.fields['phone'] = phoneController.text;
    request.fields['place'] = placeController.text;
    request.fields['post'] = postController.text;
    request.fields['pin'] = pinController.text;
    request.fields['job'] = jobController.text;
    request.fields['experience'] = expController.text;
    request.fields['category'] = selectedCategory ?? '';

    if (_image != null) {
      request.files.add(
        await http.MultipartFile.fromPath('photo', _image!.path),
      );
    }

    var response = await request.send();
    var res = await http.Response.fromStream(response);
    final data = jsonDecode(res.body);

    setState(() => isLoading = false);

    if (data['status'] == 'ok') {
      Fluttertoast.showToast(msg: "Profile Updated Successfully");
      Navigator.pop(context);
    } else {
      Fluttertoast.showToast(msg: "Update Failed");
    }
  }

  Widget textField(TextEditingController c, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: c,
        validator: (v) =>
        v == null || v.isEmpty ? 'Enter $label' : null,
        style: const TextStyle(color: whiteText),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: subText),
          filled: true,
          fillColor: cardColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: lightPurple, width: 1.5),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? imageProvider;

    if (_image != null) {
      imageProvider = FileImage(_image!);
    } else if (currentPhoto.isNotEmpty) {
      imageProvider = NetworkImage(currentPhoto);
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text(
          "Edit Profile",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(color: lightPurple),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: pickImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: cardColor,
                  backgroundImage: imageProvider,
                  child: imageProvider == null
                      ? const Icon(
                    Icons.camera_alt,
                    size: 40,
                    color: subText,
                  )
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              textField(nameController, "Name"),
              textField(phoneController, "Phone"),
              textField(placeController, "Place"),
              textField(postController, "Post"),
              textField(pinController, "Pin"),
              textField(jobController, "Job"),
              textField(expController, "Experience"),
              DropdownButtonFormField(
                value: selectedCategory,
                dropdownColor: cardColor,
                style: const TextStyle(color: whiteText),
                hint: const Text(
                  "Select Category",
                  style: TextStyle(color: subText),
                ),
                items: categories.map<DropdownMenuItem>((cat) {
                  return DropdownMenuItem(
                    value: cat['id'].toString(),
                    child: Text(
                      cat['type'],
                      style: const TextStyle(color: whiteText),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    selectedCategory = val.toString();
                  });
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                    const BorderSide(color: borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                    const BorderSide(color: borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: lightPurple,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: purple,
                  ),
                  child: const Text(
                    "UPDATE PROFILE",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}