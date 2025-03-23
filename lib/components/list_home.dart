import 'package:flutter/material.dart';
import '../import/import.dart';

class ListHome extends StatefulWidget {
  const ListHome({super.key});

  @override
  State<ListHome> createState() => _ListHomeState();
}

class _ListHomeState extends State<ListHome> {
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
        title: Text("Home Page"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => logout(),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          spacing: 16,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _menuList(context, "Stopwatch", Icons.timer, StopwatchPage()),
            _menuList(context, "Jenis Bilangan", Icons.numbers, BilanganPage()),
            _menuList(
                context, "Tracking LBS", Icons.analytics, TrackingLbsPage()),
            _menuList(context, "Konversi Waktu", Icons.av_timer_outlined,
                KonversiWaktuPage()),
            _menuList(context, "Rekomenadisasi", Icons.favorite, RekomendasiPage()),
          ],
        ),
      ),
    );
  }

  Widget _menuList(
      BuildContext context, String title, IconData icon, Widget page) {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => page,
          ),
        );
      },
      icon: Icon(icon),
      label: Text(title),
    );
  }
}
