// main_layout_admin.dart (pastikan ini digunakan sebagai root untuk admin pages)
import 'package:flutter/material.dart';
import 'admin_page.dart'; // Pastikan import AdminPage

class MainLayoutAdmin extends StatefulWidget {
  const MainLayoutAdmin({super.key});

  @override
  State<MainLayoutAdmin> createState() => _MainLayoutAdminState();
}

class _MainLayoutAdminState extends State<MainLayoutAdmin> {
  int _selectedIndex = 0;

  // Daftar halaman untuk bottom navigation
  static const List<Widget> _pages = <Widget>[
    AdminPage(), // Halaman AdminPage sebagai salah satu tab
    // Tambahkan halaman lain jika diperlukan, misalnya:
    // Center(child: Text('Halaman Lain', style: TextStyle(color: Colors.white))),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Definisi warna untuk Dark Theme (sesuai dengan AdminPage)
    const Color darkBackgroundColor = Color(0xFF121212);
    const Color cardColor = Color(0xFF1F1F1F);
    const Color cyanAccentColor = Color(0xFF00BCD4);
    const Color lightTextColor = Colors.white;
    const Color secondaryTextColor = Colors.white70;

    return Scaffold(
      backgroundColor: darkBackgroundColor,
      appBar: AppBar(
        title: const Text('Admin Panel', style: TextStyle(color: lightTextColor)),
        backgroundColor: cardColor,
        elevation: 4,
      ),
      body: _pages[_selectedIndex], // Menampilkan halaman yang dipilih
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: cardColor,
        selectedItemColor: cyanAccentColor,
        unselectedItemColor: secondaryTextColor,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'User Management',
          ),
          // Tambahkan item lain jika ada halaman tambahan
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.settings),
          //   label: 'Settings',
          // ),
        ],
      ),
    );
  }
}