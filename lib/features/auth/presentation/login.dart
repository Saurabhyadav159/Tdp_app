import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:poster/features/auth/presentation/regidtration.dart';

import '../../../constants/app_colors.dart';
import '../../../core/network/api_service.dart';
import '../../../core/shared_components.dart';
import 'Otpscreenlogin.dart';
import 'auth_screen.dart';
import 'auth_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _mobileController = TextEditingController();
  final Connectivity _connectivity = Connectivity();
  String? _mobileError;
  bool _isLoading = false;

  @override
  void dispose() {
    _mobileController.dispose();
    super.dispose();
  }

  Future<bool> _checkInternetConnection() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  void showNoInternetPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.wifi_off, size: 80, color: Colors.red),
                const SizedBox(height: 15),
                const Text(
                  "NO INTERNET CONNECTION",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Please check your internet connection and try again.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text("OK",
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void getOtp(BuildContext context) async {
    String mobile = _mobileController.text.trim();
    if (mobile.isEmpty || mobile.length != 10 || !RegExp(r'^[0-9]+$').hasMatch(mobile)) {
      setState(() {
        _mobileError = "Enter a valid mobile number";
      });
      return;
    }

    final hasInternet = await _checkInternetConnection();
    if (!hasInternet) {
      showNoInternetPopup(context);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService().sendOtp(mobile);
      if (response["message"] == "OTP sent succesfully") {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => OtpScreenLogin(mobile: mobile)),
        );
      } else {
        setState(() {
          _isLoading = false;
          _mobileError = "An error occurred while sending OTP";
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _mobileError = "Account not found, Please register first!";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Top Purple Curved Background
          Container(
            height: 420,
            decoration: const BoxDecoration(
              color: AppColors.accentOrange,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(50),
              ),
            ),
            child: const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 80.0),
                child: Text(
                  'Welcome',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // Main White Card
          Align(
            alignment: Alignment.center,
            child: Container(
              margin: const EdgeInsets.only(top: 180),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                  )
                ],
              ),
              width: MediaQuery.of(context).size.width * 0.85,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Circular App Logo
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: const CircleAvatar(
                      radius: 30,
                      backgroundImage: const AssetImage("assets/app_icon.png"),
                    )
                  ),
                  const SizedBox(height: 20),

                  // Mobile Number Field
                  AuthTextField(
                    "Enter your mobile number",
                    iconName: "assets/phone.png",
                    controller: _mobileController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(10),
                    ],
                  ),

                  if (_mobileError != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                      child: Text(
                        _mobileError!,
                        style: const TextStyle(color: Colors.red, fontSize: 12.0),
                      ),
                    ),

                  const SizedBox(height: 24.0),

                  // Get OTP Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => getOtp(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentRed,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.0,
                      )
                          : const Text(
                        "Get OTP",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Create Account Button
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RegistrationScreen()),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      "Create Account",
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.black,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
