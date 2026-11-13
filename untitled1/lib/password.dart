
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'user/userhome.dart';
import 'package:untitled1/login.dart';
import 'worker/workershome.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: changepassword(title: 'Change Password'),
  ));
}

class changepassword extends StatefulWidget {
  const changepassword({super.key, required this.title});

  final String title;
  @override
  State<changepassword> createState() => _changepasswordState();
}

class _changepasswordState extends State<changepassword> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _cpasswordtextController = TextEditingController();
  final TextEditingController _npasswordtextController = TextEditingController();
  final TextEditingController _conpasswordtextController = TextEditingController();

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String _errorMessage = '';
  File? _selectedImage;

  Future<void> _chooseImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    } else {
      Fluttertoast.showToast(msg: "No image selected");
    }
  }

  Future<void> _sendData() async {
    String ucpassword = _cpasswordtextController.text;
    String unpassword = _npasswordtextController.text;
    String uconpassword = _conpasswordtextController.text;

    // Enhanced validation
    if (unpassword == ucpassword) {
      setState(() {
        _errorMessage = 'New password must be different from current password';
      });
      Fluttertoast.showToast(msg: "New password must be different from current password");
      return;
    }

    // Password strength validation
    if (unpassword.length < 8) {
      setState(() {
        _errorMessage = 'Password must be at least 8 characters long';
      });
      return;
    }

    if (!RegExp(r'[A-Z]').hasMatch(unpassword)) {
      setState(() {
        _errorMessage = 'Password must contain at least one uppercase letter';
      });
      return;
    }

    if (!RegExp(r'[a-z]').hasMatch(unpassword)) {
      setState(() {
        _errorMessage = 'Password must contain at least one lowercase letter';
      });
      return;
    }

    if (!RegExp(r'[0-9]').hasMatch(unpassword)) {
      setState(() {
        _errorMessage = 'Password must contain at least one number';
      });
      return;
    }

    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(unpassword)) {
      setState(() {
        _errorMessage = 'Password must contain at least one special character';
      });
      return;
    }

    if (!_formKey.currentState!.validate()) {
      Fluttertoast.showToast(msg: "Please fix errors in the form");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    SharedPreferences sh = await SharedPreferences.getInstance();
    String? url = sh.getString('url');
    String? lid = sh.getString('lid');
    String? dmid = sh.getString('dmid');

    if (url == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Server URL not found.";
      });
      Fluttertoast.showToast(msg: "Server URL not found.");
      return;
    }

    final uri = Uri.parse('$url/fluttchangepassword/');
    var request = http.MultipartRequest('POST', uri);
    request.fields['ucpassword'] = ucpassword;
    request.fields['unpassword'] = unpassword;
    request.fields['uconpassword'] = uconpassword;
    request.fields['lid'] = lid.toString();

    if (_selectedImage != null) {
      request.files.add(await http.MultipartFile.fromPath('photo', _selectedImage!.path));
    }

    try {
      var response = await request.send();
      var respStr = await response.stream.bytesToString();
      var data = jsonDecode(respStr);

      if (response.statusCode == 200 && data['status'] == 'ok') {
        Fluttertoast.showToast(
          msg: "Password changed successfully!",
          backgroundColor: Colors.green,
          textColor: Colors.white,
          gravity: ToastGravity.CENTER,
        );

        // Clear all fields
        _cpasswordtextController.clear();
        _npasswordtextController.clear();
        _conpasswordtextController.clear();

        // Navigate to login page
        await Future.delayed(const Duration(seconds: 2));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MyLoginPage(title: '')),
        );
      } else {
        String errorMsg = data['message'] ?? "Failed to change password. Please check your current password.";
        setState(() {
          _errorMessage = errorMsg;
        });
        Fluttertoast.showToast(
          msg: errorMsg,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Network error. Please check your connection.";
      });
      Fluttertoast.showToast(
        msg: "Error: $e",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool obscureText,
    required VoidCallback onToggle,
    required String? Function(String?)? validator,
    bool isCurrentPassword = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.blueGrey,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: TextFormField(
              controller: controller,
              obscureText: obscureText,
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                prefixIcon: Icon(
                  Icons.lock_outline,
                  color: Colors.blue.shade600,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                    color: Colors.blue.shade600,
                  ),
                  onPressed: onToggle,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              validator: validator,
              onChanged: (value) {
                if (value.isNotEmpty) {
                  setState(() {
                    _errorMessage = '';
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordRequirement(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.circle,
            size: 16,
            color: isMet ? Colors.green : Colors.grey[400],
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: isMet ? Colors.green : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const UserHomePage()),
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: Text(
            'Change Password',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20,
              color: Colors.blue.shade800,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 1,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const WorkerHomePage()),
              );
            },
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Header
                Container(
                  margin: const EdgeInsets.only(bottom: 30),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.blue.shade100, width: 2),
                        ),
                        child: Icon(
                          Icons.lock_reset,
                          size: 40,
                          color: Colors.blue.shade600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Update Your Password",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Create a strong and secure password",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // Current Password
                _buildPasswordField(
                  controller: _cpasswordtextController,
                  label: "Current Password",
                  hint: "Enter your current password",
                  obscureText: _obscureCurrentPassword,
                  onToggle: () => setState(() => _obscureCurrentPassword = !_obscureCurrentPassword),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Current password is required';
                    }
                    return null;
                  },
                  isCurrentPassword: true,
                ),

                // New Password
                _buildPasswordField(
                  controller: _npasswordtextController,
                  label: "New Password",
                  hint: "Enter new password",
                  obscureText: _obscureNewPassword,
                  onToggle: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'New password is required';
                    }
                    return null;
                  },
                ),

                // Password Requirements
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade100),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Password Requirements:",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildPasswordRequirement(
                        "At least 8 characters long",
                        _npasswordtextController.text.length >= 8,
                      ),
                      _buildPasswordRequirement(
                        "Contains uppercase letter",
                        RegExp(r'[A-Z]').hasMatch(_npasswordtextController.text),
                      ),
                      _buildPasswordRequirement(
                        "Contains lowercase letter",
                        RegExp(r'[a-z]').hasMatch(_npasswordtextController.text),
                      ),
                      _buildPasswordRequirement(
                        "Contains a number",
                        RegExp(r'[0-9]').hasMatch(_npasswordtextController.text),
                      ),
                      _buildPasswordRequirement(
                        "Contains special character",
                        RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(_npasswordtextController.text),
                      ),
                      _buildPasswordRequirement(
                        "Different from current password",
                        _npasswordtextController.text != _cpasswordtextController.text &&
                            _cpasswordtextController.text.isNotEmpty,
                      ),
                    ],
                  ),
                ),

                // Confirm Password
                _buildPasswordField(
                  controller: _conpasswordtextController,
                  label: "Confirm New Password",
                  hint: "Re-enter new password",
                  obscureText: _obscureConfirmPassword,
                  onToggle: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _npasswordtextController.text) {
                      return "Passwords don't match";
                    }
                    return null;
                  },
                ),

                // Error Message
                if (_errorMessage.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade100),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade600),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _errorMessage,
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Submit Button
                Container(
                  margin: const EdgeInsets.only(top: 24, bottom: 16),
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _sendData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      shadowColor: Colors.blue.shade100,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                        : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.lock_open, size: 20),
                        SizedBox(width: 10),
                        Text(
                          "Change Password",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Security Note
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.security, size: 16, color: Colors.blue.shade600),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "You will be logged out after changing your password",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}