import 'package:flutter/material.dart';
import 'dart:math'; // OTP generation ke liye

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  String? _generatedOtp; // Terminal mein check karne ke liye

  void _validateAndSignup() {
    String name = _nameCtrl.text.trim();
    String email = _emailCtrl.text.trim();
    String phone = _phoneCtrl.text.trim();
    String password = _passCtrl.text.trim();

    if (name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty) {
      _showSnackBar("⚠️ Sabhi fields bharna lazmi hain!", Colors.orange);
      return;
    }

    if (name.length < 3) {
      _showSnackBar("👤 Naam kam se kam 3 characters ka ho", Colors.redAccent);
      return;
    }

    bool emailValid = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    ).hasMatch(email);
    if (!emailValid) {
      _showSnackBar("📧 Email format galat hai!", Colors.redAccent);
      return;
    }

    if (phone.length < 10) {
      _showSnackBar("📱 Phone number sahi darj karein", Colors.redAccent);
      return;
    }

    if (password.length < 8) {
      _showSnackBar(
        "🔑 Password kam se kam 8 characters ka ho",
        Colors.redAccent,
      );
      return;
    }

    // 🔥 GENERATE RANDOM OTP FOR TERMINAL LOGGING
    _generatedOtp = (Random().nextInt(9000) + 1000).toString();

    // 🖥️ TERMINAL LOGS
    debugPrint("-----------------------------------------");
    debugPrint("🚀 SIGNUP INITIATED");
    debugPrint("👤 NAME: $name");
    debugPrint("📧 EMAIL: $email");
    debugPrint("📱 PHONE: $phone");
    debugPrint("🔑 PASSWORD: [PROTECTED]");
    debugPrint("🔢 GENERATED OTP: $_generatedOtp  <-- ISAY USE KAREIN");
    debugPrint("-----------------------------------------");

    _showOtpDialog(context);
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "CREATE ACCOUNT",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Join CyberShield AI Security. Har user ka data ID-based aur private hoga.",
              style: TextStyle(color: Colors.white38, fontSize: 13),
            ),
            const SizedBox(height: 40),
            _buildField(_nameCtrl, "Full Name", Icons.person_outline),
            _buildField(
              _emailCtrl,
              "Email Address",
              Icons.email_outlined,
              type: TextInputType.emailAddress,
            ),
            _buildField(
              _phoneCtrl,
              "Phone Number",
              Icons.phone_android_outlined,
              type: TextInputType.phone,
            ),
            _buildField(
              _passCtrl,
              "Password",
              Icons.lock_outline,
              isPass: true,
            ),
            const SizedBox(height: 30),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 55),
        backgroundColor: Colors.cyanAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 8,
        shadowColor: Colors.cyanAccent.withOpacity(0.3),
      ),
      onPressed: _validateAndSignup,
      child: const Text(
        "GENERATE OTP",
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  void _showOtpDialog(BuildContext context) {
    final _otpCtrl = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0D1117),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.cyanAccent, width: 0.5),
        ),
        title: const Text(
          "VERIFY IDENTITY",
          style: TextStyle(
            color: Colors.cyanAccent,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Terminal mein check karein, OTP bhej di gayi hai.",
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _otpCtrl,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 26,
                letterSpacing: 15,
                color: Colors.cyanAccent,
                fontWeight: FontWeight.bold,
              ),
              keyboardType: TextInputType.number,
              maxLength: 4,
              decoration: const InputDecoration(
                counterText: "",
                hintText: "0000",
                hintStyle: TextStyle(color: Colors.white10),
                border: InputBorder.none,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "CANCEL",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent),
            onPressed: () {
              // 🖥️ LOG OTP ATTEMPT
              debugPrint("⌨️ USER ENTERED OTP: ${_otpCtrl.text}");

              if (_otpCtrl.text == _generatedOtp) {
                debugPrint("✅ OTP VERIFIED SUCCESSFULLY");
                debugPrint(
                  "💾 SAVING TO BACKEND: name=${_nameCtrl.text}, email=${_emailCtrl.text}",
                );
                Navigator.pushReplacementNamed(context, '/scan');
              } else {
                debugPrint("❌ WRONG OTP ENTERED");
                _showSnackBar(
                  "❌ Galat OTP! Terminal check karein.",
                  Colors.red,
                );
              }
            },
            child: const Text(
              "VERIFY & REGISTER",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    bool isPass = false,
    TextInputType type = TextInputType.text,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: TextField(
        controller: ctrl,
        obscureText: isPass,
        keyboardType: type,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
          icon: Icon(icon, color: Colors.cyanAccent, size: 20),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
