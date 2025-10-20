// admin_page.dart (versi diperbaiki untuk menghindari error "Looking up a deactivated widget")
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  bool _hasAccess = false;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
    _checkAdminAccess();
  }

  Future<void> _checkAdminAccess() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {  // Cek mounted sebelum setState
        setState(() {
          _isChecking = false;
          _hasAccess = false;
        });
      }
      return;
    }

    final doc =
        await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

    if (mounted) {  // Cek mounted sebelum setState
      if (doc.exists && doc.data()?['role'] == 'admin') {
        setState(() {
          _hasAccess = true;
          _isChecking = false;
        });
      } else {
        setState(() {
          _hasAccess = false;
          _isChecking = false;
        });
      }
    }
  }

  Future<void> _deleteUser(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(docId).delete();
      if (mounted) {  // Cek mounted sebelum menggunakan context
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User berhasil dihapus.")),
        );
      }
    } catch (e) {
      if (mounted) {  // Cek mounted sebelum menggunakan context
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal menghapus user: $e")),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Definisi warna untuk Dark Theme
    const Color darkBackgroundColor = Color(0xFF121212); // Warna latar belakang sangat gelap
    const Color cardColor = Color(0xFF1F1F1F); // Warna untuk kontainer/card
    const Color cyanAccentColor = Color(0xFF00BCD4); // Cyan untuk aksen
    const Color lightTextColor = Colors.white;
    const Color secondaryTextColor = Colors.white70;

    // Menampilkan loading state
    if (_isChecking) {
      return const Center(
        child: CircularProgressIndicator(color: cyanAccentColor),
      );
    }

    // Menampilkan akses ditolak
    if (!_hasAccess) {
      return Container(
        // Bungkus dengan Container dan beri warna gelap
        color: darkBackgroundColor,
        child: const Center(
          child: Text(
            "🚫 Akses ditolak.\nHanya admin yang dapat membuka halaman ini.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.redAccent, fontSize: 16),
          ),
        ),
      );
    }

    // Return body tanpa Scaffold (karena Scaffold ada di MainLayoutAdmin)
    return FadeTransition(
      opacity: _fadeAnim,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: cyanAccentColor));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "Belum ada user terdaftar.",
                style: TextStyle(color: secondaryTextColor),
              ),
            );
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final data = users[index].data() as Map<String, dynamic>;
              final joinedAt = data['joinedAt'] ?? data['createdAt'];

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  // Warna card yang lebih gelap
                  color: cardColor, 
                  borderRadius: BorderRadius.circular(14),
                  // Garis tepi aksen
                  border: Border.all(color: cyanAccentColor.withOpacity(0.3)), 
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ListTile(
                  leading: const Icon(Icons.person, color: cyanAccentColor),
                  title: Text(
                    data['name'] ?? 'Tanpa Nama',
                    style: const TextStyle(
                      color: lightTextColor, // Teks terang
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    "Email: ${data['email'] ?? '-'}\n"
                    "Bergabung: ${joinedAt != null ? DateFormat('dd MMM yyyy, HH:mm').format((joinedAt as Timestamp).toDate()) : '-'}",
                    style: const TextStyle(
                        color: secondaryTextColor, fontSize: 13), // Teks sekunder
                  ),
                  isThreeLine: true,
                  trailing: PopupMenuButton<String>(
                    color: cardColor, // Warna menu gelap
                    onSelected: (value) async {
                      if (value == 'delete') {
                        _deleteUser(users[index].id);
                      } else if (value == 'detail') {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            // Warna Dialog gelap
                            backgroundColor: cardColor, 
                            title: const Text("Detail User",
                                style: TextStyle(color: cyanAccentColor)),
                            content: Text(
                              "Nama: ${data['name'] ?? '-'}\n"
                              "Email: ${data['email'] ?? '-'}\n"
                              "No HP: ${data['phone'] ?? '-'}\n"
                              "Alamat: ${data['address'] ?? '-'}\n"
                              "Bergabung: ${joinedAt != null ? DateFormat('dd MMM yyyy, HH:mm').format((joinedAt as Timestamp).toDate()) : '-'}",
                              style: const TextStyle(color: lightTextColor), // Teks terang
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Tutup",
                                    style: TextStyle(color: cyanAccentColor)),
                              )
                            ],
                          ),
                        );
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'detail',
                        child: Row(
                          children: [
                            Icon(Icons.info,
                                color: cyanAccentColor, size: 18),
                            SizedBox(width: 8),
                            Text("Detail",
                                style: TextStyle(color: lightTextColor)), // Teks terang
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete,
                                color: Colors.redAccent, size: 18),
                            SizedBox(width: 8),
                            Text("Hapus",
                                style: TextStyle(color: lightTextColor)), // Teks terang
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}