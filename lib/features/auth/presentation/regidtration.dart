import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';

import '../../../config/colors.dart';
import '../../../core/network/api_service.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;
  bool _isPhoneVerified = false;
  bool _showVerifyButton = false;
  bool _isSendingOtp = false;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_checkPhoneNumber);
  }

  @override
  void dispose() {
    _phoneController.removeListener(_checkPhoneNumber);
    super.dispose();
  }

  void _checkPhoneNumber() {
    setState(() {
      _showVerifyButton = _phoneController.text.length == 10;
    });
  }

  Future<void> _sendOtp() async {
    if (_phoneController.text.length != 10) return;

    setState(() => _isSendingOtp = true);

    try {
      ApiService apiService = ApiService();
      final response = await apiService.sendOtpForRegistration(
        phoneNumber: _phoneController.text.trim(),
      );

      if (response.data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(
              response.data['message'] ?? 'OTP sent successfully')),
        );
        _showOtpDialog();
      }
    } on DioException catch (e) {
      String errorMessage = "Failed to send OTP";
      if (e.response != null) {
        if (e.response?.statusCode == 409) {
          errorMessage =
              e.response?.data?['message'] ?? "Phone number already exists";
        } else {
          errorMessage +=
          ": ${e.response?.data?['message'] ?? e.response?.statusMessage ??
              'Unknown error'}";
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    } finally {
      setState(() => _isSendingOtp = false);
    }
  }

  void _showOtpDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          AlertDialog(
            title: Text("Verify OTP"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Enter 6-digit OTP sent to ${_phoneController.text}"),
                SizedBox(height: 20),
                TextFormField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: InputDecoration(
                    labelText: "OTP",
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: _verifyOtp,
                child: Text("Verify"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SharedColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter a valid 6-digit OTP")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      ApiService apiService = ApiService();
      final response = await apiService.verifyOtpForRegistration(
        phoneNumber: _phoneController.text.trim(),
        otp: _otpController.text.trim(),
      );

      if (response.data['success'] == true) {
        setState(() {
          _isPhoneVerified = true;
        });
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(
              response.data['message'] ?? 'OTP verified successfully')),
        );
      }
    } on DioException catch (e) {
      String errorMessage = "OTP verification failed";
      if (e.response != null) {
        errorMessage +=
        ": ${e.response?.data?['message'] ?? e.response?.statusMessage ??
            'Invalid OTP'}";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _registerUser() async {
    if (!_isPhoneVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please verify your phone number first")),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        ApiService apiService = ApiService();
        final response = await apiService.registerUser(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Registration Successful!")),
        );
        Navigator.pop(context);
      } on DioException catch (e) {
        String errorMessage = "Registration Failed";
        if (e.response != null) {
          errorMessage +=
          ": ${e.response?.data?['message'] ?? e.response?.statusMessage ??
              'Invalid request'}";
          debugPrint("Full error response: ${e.response?.data}");
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}")),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  const SizedBox(height: 20),
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.transparent, // No background color
                    backgroundImage: AssetImage("assets/app_icon.png"), // Icon from assets
                  ),

                  const SizedBox(height: 30),

                  /// Name Field
                  _buildTextField(
                    controller: _nameController,
                    label: "Enter Name*",
                    icon: Icons.person,
                    validator: (value) =>
                    value!.isEmpty
                        ? "Name is required"
                        : null,
                  ),

                  const SizedBox(height: 15),

                  /// Email Field (optional based on your API response)
                  _buildTextField(
                    controller: _emailController,
                    label: "Enter Email *",
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value!.isNotEmpty && !RegExp(
                          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                          .hasMatch(value)) {
                        return "Enter a valid email";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 15),

                  /// Phone Number Field with Verify Button
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _phoneController,
                          label: "Enter Phone Number*",
                          icon: Icons.phone,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [  // Add this parameter
                            FilteringTextInputFormatter.digitsOnly,  // Only allow digits
                            LengthLimitingTextInputFormatter(10),    // Limit to 10 characters
                          ],
                          validator: (value) {
                            if (value!.isEmpty) return "Phone number is required";
                            if (value.length != 10) return "Enter a valid 10-digit phone number";
                            return null;
                          },
                        ),
                      ),
                      if (_showVerifyButton && !_isPhoneVerified)
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: _isSendingOtp
                              ? CircularProgressIndicator()
                              : ElevatedButton(
                            onPressed: _sendOtp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: SharedColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              "Verify",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      if (_isPhoneVerified)
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Icon(Icons.verified, color: Colors.green),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  /// Register Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SharedColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 4,
                      ),
                      onPressed: _isLoading ? null : _registerUser,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                        "Register",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  /// Navigation to Login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account? "),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Text(
                          "Login",
                          style: TextStyle(
                              color: Colors.purple,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters, // Add this new parameter
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      inputFormatters: inputFormatters,
      // Add this line
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
            vertical: 14, horizontal: 10),
      ),
    );
  }
}