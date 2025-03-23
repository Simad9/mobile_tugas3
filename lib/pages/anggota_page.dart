import 'package:flutter/material.dart';
import '../import/import.dart';

class AnggotaPage extends StatefulWidget {
  const AnggotaPage({super.key});

  @override
  State<AnggotaPage> createState() => _AnggotaPageState();
}

class _AnggotaPageState extends State<AnggotaPage> {
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('session_token'); // Hapus session token
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => LoginPage()), // Arahkan ke halaman login
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Anggota Page"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => logout(),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            spacing: 16,
            children: [
              _anggotaList("assets/images/fotowijdan.jpg", "Wijdan Akhmad S",
                  "123220010"),
              _anggotaList("assets/images/fotoaqsha.jpg",
                  "Aqsha Jauzaarafa S.H.", "123220016"),
              _anggotaList(
                  "assets/images/fotorani.jpg", "Vrida Pusparani", "123220082"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _anggotaList(String path, String nama, String nim) {
    return Row(
      spacing: 8,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(path, width: 100),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Nama : $nama",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text("NIM : $nim"),
          ],
        )
      ],
    );
  }
}
