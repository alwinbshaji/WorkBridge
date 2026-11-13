
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({Key? key}) : super(key: key);

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final _formKey = GlobalKey<FormState>();

  bool isEditing = false;
  bool isLoading = false;
  bool isSaving = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController placeController = TextEditingController();
  final TextEditingController pinController = TextEditingController();
  final TextEditingController postController = TextEditingController();

  File? _image;
  String photoUrl = "";

  final ImagePicker _picker = ImagePicker();

  static const Color primary = Color(0xFF0B1F3A);
  static const Color secondary = Color(0xFF163E73);
  static const Color accent = Color(0xFF2F80ED);
  static const Color bgColor = Color(0xFFF5F7FB);
  static const Color cardColor = Colors.white;
  static const Color textDark = Color(0xFF1B2A41);
  static const Color textLight = Color(0xFF6B7A90);
  static const Color borderColor = Color(0xFFE6ECF5);

  @override
  void initState() {
    super.initState();
    initProfile();
  }

  String cleanBaseUrl(String url) {
    if (url.endsWith("/")) {
      url = url.substring(0, url.length - 1);
    }
    if (url.contains("/myapp")) {
      url = url.replaceAll("/myapp", "");
    }
    return url;
  }

  Future<void> initProfile() async {
    await loadCachedProfile();
    fetchProfile(showToastOnError: false);
  }

  Future<void> loadCachedProfile() async {
    final sp = await SharedPreferences.getInstance();

    setState(() {
      nameController.text = sp.getString('profile_name') ?? "";
      phoneController.text = sp.getString('profile_phone') ?? "";
      emailController.text = sp.getString('profile_email') ?? "";
      placeController.text = sp.getString('profile_place') ?? "";
      pinController.text = sp.getString('profile_pin') ?? "";
      postController.text = sp.getString('profile_post') ?? "";
      photoUrl = sp.getString('profile_photo') ?? "";
    });
  }

  Future<void> saveProfileCache({
    required String name,
    required String phone,
    required String email,
    required String place,
    required String pin,
    required String post,
    required String photo,
  }) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString('profile_name', name);
    await sp.setString('profile_phone', phone);
    await sp.setString('profile_email', email);
    await sp.setString('profile_place', place);
    await sp.setString('profile_pin', pin);
    await sp.setString('profile_post', post);
    await sp.setString('profile_photo', photo);
  }

  Future<void> fetchProfile({bool showToastOnError = true}) async {
    try {
      final sp = await SharedPreferences.getInstance();
      String baseUrl = sp.getString('url') ?? '';
      String lid = sp.getString('lid') ?? '';

      baseUrl = cleanBaseUrl(baseUrl);

      final response = await http.post(
        Uri.parse('$baseUrl/myapp/view_profile/'),
        body: {"lid": lid},
      ).timeout(const Duration(seconds: 8));

      final data = jsonDecode(response.body);

      if (data['status'] == 'ok') {
        String newPhotoUrl = "";

        if (data['photo'] != null && data['photo'].toString().isNotEmpty) {
          String imagePath = data['photo'].toString();

          if (imagePath.startsWith("/")) {
            imagePath = imagePath.substring(1);
          }

          if (!imagePath.startsWith("media/")) {
            imagePath = "media/$imagePath";
          }

          newPhotoUrl =
          "$baseUrl/$imagePath?t=${DateTime.now().millisecondsSinceEpoch}";
        }

        await saveProfileCache(
          name: data['name']?.toString() ?? "",
          phone: data['phone']?.toString() ?? "",
          email: data['email']?.toString() ?? "",
          place: data['place']?.toString() ?? "",
          pin: data['pin']?.toString() ?? "",
          post: data['post']?.toString() ?? "",
          photo: newPhotoUrl,
        );

        if (!mounted) return;

        setState(() {
          nameController.text = data['name']?.toString() ?? "";
          phoneController.text = data['phone']?.toString() ?? "";
          emailController.text = data['email']?.toString() ?? "";
          placeController.text = data['place']?.toString() ?? "";
          pinController.text = data['pin']?.toString() ?? "";
          postController.text = data['post']?.toString() ?? "";
          photoUrl = newPhotoUrl;
        });
      } else {
        if (showToastOnError) {
          Fluttertoast.showToast(msg: "Failed to load profile");
        }
      }
    } catch (e) {
      if (showToastOnError) {
        Fluttertoast.showToast(msg: "Error loading profile");
      }
      print("Profile Fetch Error: $e");
    }
  }

  Future<void> pickImage() async {
    final XFile? picked =
    await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);

    if (picked != null) {
      setState(() {
        _image = File(picked.path);
      });
    }
  }

  Future<void> updateProfile() async {
    try {
      setState(() {
        isSaving = true;
      });

      final sp = await SharedPreferences.getInstance();
      String baseUrl = sp.getString('url') ?? '';
      String lid = sp.getString('lid') ?? '';

      baseUrl = cleanBaseUrl(baseUrl);

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/myapp/update_profile/'),
      );

      request.fields['lid'] = lid;
      request.fields['name'] = nameController.text;
      request.fields['phone'] = phoneController.text;
      request.fields['email'] = emailController.text;
      request.fields['place'] = placeController.text;
      request.fields['pin'] = pinController.text;
      request.fields['post'] = postController.text;

      if (_image != null) {
        request.files.add(
          await http.MultipartFile.fromPath('photo', _image!.path),
        );
      }

      final streamedResponse = await request.send();
      final res = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(res.body);

      if (data['status'] == 'ok') {
        setState(() {
          isEditing = false;
        });

        await fetchProfile(showToastOnError: false);

        setState(() {
          _image = null;
          isSaving = false;
        });

        Fluttertoast.showToast(msg: "Profile Updated Successfully");
      } else {
        setState(() {
          isSaving = false;
        });
        Fluttertoast.showToast(msg: "Update Failed");
      }
    } catch (e) {
      setState(() {
        isSaving = false;
      });
      Fluttertoast.showToast(msg: "Error updating profile");
      print("Update Error: $e");
    }
  }

  Widget buildTextField(
      String label,
      TextEditingController controller,
      IconData icon,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        enabled: isEditing && !isSaving,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "$label is required";
          }
          return null;
        },
        style: const TextStyle(
          color: textDark,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: secondary),
          labelText: label,
          labelStyle: const TextStyle(color: textLight),
          filled: true,
          fillColor: isEditing ? Colors.white : const Color(0xFFF8FAFC),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: borderColor),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: accent, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red),
          ),
        ),
      ),
    );
  }

  Widget buildProfileImage() {
    ImageProvider? imageProvider;

    if (_image != null) {
      imageProvider = FileImage(_image!);
    } else if (photoUrl.isNotEmpty) {
      imageProvider = NetworkImage(photoUrl);
    }

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: const [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 14,
                offset: Offset(0, 6),
              )
            ],
          ),
          child: CircleAvatar(
            radius: 58,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: imageProvider,
            child: (imageProvider == null)
                ? const Icon(Icons.person, size: 54, color: textLight)
                : null,
          ),
        ),
        if (isEditing && !isSaving)
          GestureDetector(
            onTap: pickImage,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: accent,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
      ],
    );
  }

  Widget buildTopHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 80),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [primary, secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          const Text(
            "My Profile",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildProfileCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(18, 72, 18, 18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Text(
              nameController.text.isEmpty ? "User Name" : nameController.text,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              emailController.text.isEmpty
                  ? "user@email.com"
                  : emailController.text,
              style: const TextStyle(
                fontSize: 13,
                color: textLight,
              ),
            ),
            const SizedBox(height: 24),
            buildTextField("Name", nameController, Icons.person_outline_rounded),
            buildTextField("Phone", phoneController, Icons.phone_outlined),
            buildTextField("Email", emailController, Icons.email_outlined),
            buildTextField("Place", placeController, Icons.location_on_outlined),
            buildTextField(
              "Post",
              postController,
              Icons.local_post_office_outlined,
            ),
            buildTextField("Pin", pinController, Icons.pin_drop_outlined),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: isSaving
                    ? null
                    : () {
                  if (isEditing) {
                    if (_formKey.currentState!.validate()) {
                      updateProfile();
                    }
                  } else {
                    setState(() {
                      isEditing = true;
                    });
                  }
                },
                icon: isSaving
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.4,
                  ),
                )
                    : Icon(
                  isEditing ? Icons.save_rounded : Icons.edit_rounded,
                ),
                label: Text(
                  isSaving
                      ? "Saving..."
                      : (isEditing ? "Save Changes" : "Edit Profile"),
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isEditing ? accent : primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            if (isEditing) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                    setState(() {
                      isEditing = false;
                      _image = null;
                    });
                    await loadCachedProfile();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primary,
                    side: const BorderSide(color: borderColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    placeController.dispose();
    pinController.dispose();
    postController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: RefreshIndicator(
        onRefresh: () => fetchProfile(showToastOnError: false),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              buildTopHeader(),
              Transform.translate(
                offset: const Offset(0, -50),
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 58),
                      child: buildProfileCard(),
                    ),
                    buildProfileImage(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}