import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import './register.dart';
import '../staff/staff_shell.dart';
import '../student/student_shell.dart';
import '../lecturer/lecturer_shell.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

// Function Log-in 
class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

//เงื่อนไขของพวก username กับ password 
  Future<void> _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty && password.isEmpty) {
      _showDialog("Please fill username and password.");
      return;
    } else if (username.isEmpty) {
     _showDialog("Please fill username.");
      return;
    } else if (password.isEmpty) {
       _showDialog("Please fill password.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://192.168.0.100:3000/api/login'), 
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final role = data['user']['role'];
        if (!mounted) return;

        if (role == 'student') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const StudentShell()),
          );
        } else if (role == 'staff') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const StaffShell()),
          );
        } else if (role == 'lecturer') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LecturerShell()),
          );
        }
      } else {
        _showDialog("${data['message']}");
      }
    } catch (e) {
      _showDialog("⚠️ Connection error: $e");
    }
    setState(() => _isLoading = false);
  }

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Room Booking"),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFeF3E2),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // โลโก้
                Container(
                    padding: const EdgeInsets.all(20),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20), 
                      child: Image.asset(
                        'assets/logo.png',
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover, 
                      ),
                    ),
                  ),
                  
                // ชื่อ 
                const SizedBox(height: 5),
                const Text(
                  "Room Booking",
                  style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),

                // Username 
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: "Username",
                    hintText: "Enter your username",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 20),

                // Password 
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: "Password",
                    hintText: "Enter your password",
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 30),

                 // Sign In 
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDD0303),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                          "Sign In", 
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 25),

                 // Register here
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don’t have an account? "),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const RegisterPage()),
                        );
                      },
                      child: const Text(
                        "Register here",
                        style: TextStyle(
                          color: Color(0xFFDD0303),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
