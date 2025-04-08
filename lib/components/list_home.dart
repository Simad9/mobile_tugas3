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
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 8),
            _menuList(context, "Stopwatch", Icons.timer, StopwatchPage()),
            SizedBox(height: 16),
            _menuList(context, "Jenis Bilangan", Icons.calculate, BilanganPage()),
            SizedBox(height: 16),
            _menuList(
                context, "Tracking LBS (Location-Based Service)", Icons.analytics, TrackingLbsPage()),
            SizedBox(height: 16),
            _menuList(context, "Konversi Waktu", Icons.av_timer_outlined,
                KonversiWaktuPage()),
            SizedBox(height: 16),
            _menuList(context, "Rekomendasi", Icons.favorite, EduWebListPage()),
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
      label: Expanded(
        child: Text(
          title,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 14),
        ),
      ),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        alignment: Alignment.centerLeft,
      ),
    );
  }
}