import 'package:flutter/material.dart';
import '../import/import.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> login() async {
    // Simulasi login, misalnya dengan username "user" dan password "password"
    if (usernameController.text.isNotEmpty || passwordController.text.isNotEmpty) {
      // Ambil dari inputan aja
      String session = usernameController.text + passwordController.text;

      // Simpan token session
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('session_token', session);

      // Beralih ke halaman Home setelah login berhasil
      // Check if the widget is still mounted before navigating
      if (mounted) {
        // Use pushReplacement to navigate to HomePage and remove the current page from the stack
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      }
    } else {
      // Jika login gagal
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Login Gagal'),
          content: Text('Username atau Password tidak boleh kosong'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            children: [
              TextField(
                controller: usernameController,
                decoration: InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Password'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: login,
                child: Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
