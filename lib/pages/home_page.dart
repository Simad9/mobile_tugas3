import 'package:flutter/material.dart';
import 'package:mobile_tugas3/import/import.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String? sessionToken;

  @override
  void initState() {
    super.initState();
    checkSession(); // Cek session saat halaman dimuat
    debugPrint('Session Token: $sessionToken');
  }

  Future<void> checkSession() async {
    // Ambil session token dari SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    sessionToken =
        prefs.getString('session_token'); // Mendapatkan session token

    // Jika session token tidak ada, arahkan ke halaman login
    if (sessionToken == null) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      }
    }
  }

  final List<Widget> _pages = <Widget>[
    ListHome(),
    AnggotaPage(),
    BantuanPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: _pages.elementAt(_selectedIndex),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Anggota"),
          BottomNavigationBarItem(icon: Icon(Icons.help), label: "Bantuan"),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType
            .fixed, // Agar item tidak hilang saat ada banyak
      ),
    );
  }
}
