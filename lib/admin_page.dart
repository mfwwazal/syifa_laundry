import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'main_layout_admin.dart';

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
      setState(() {
        _isChecking = false;
        _hasAccess = false;
      });
      return;
    }

    final doc =
        await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

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

  Future<void> _deleteUser(String docId) async {
    await FirebaseFirestore.instance.collection('users').doc(docId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("User berhasil dihapus.")),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
  const Color cyanLight = Color(0xFF63B9C4);

  if (_isChecking) {
    return const Center(
      child: CircularProgressIndicator(color: Colors.cyanAccent),
    );
  }

  if (!_hasAccess) {
    return const Center(
      child: Text(
        "🚫 Akses ditolak.\nHanya admin yang dapat membuka halaman ini.",
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.redAccent, fontSize: 16),
      ),
    );
  }

  return FadeTransition(
    opacity: _fadeAnim,
    child: StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.cyanAccent));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              "Belum ada user terdaftar.",
              style: TextStyle(color: Colors.white70),
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
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border:
                    Border.all(color: cyanLight.withOpacity(0.3)),
              ),
              child: ListTile(
                leading:
                    const Icon(Icons.person, color: Colors.cyanAccent),
                title: Text(
                  data['name'] ?? 'Tanpa Nama',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  "Email: ${data['email'] ?? '-'}\n"
                  "Bergabung: ${joinedAt != null ? DateFormat('dd MMM yyyy, HH:mm').format((joinedAt as Timestamp).toDate()) : '-'}",
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                isThreeLine: true,
                trailing: PopupMenuButton<String>(
                  color: Colors.black,
                  onSelected: (value) async {
                    if (value == 'delete') {
                      _deleteUser(users[index].id);
                    } else if (value == 'detail') {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          backgroundColor: const Color(0xFF1B2E35),
                          title: const Text("Detail User",
                              style:
                                  TextStyle(color: Colors.cyanAccent)),
                          content: Text(
                            "Nama: ${data['name'] ?? '-'}\n"
                            "Email: ${data['email'] ?? '-'}\n"
                            "No HP: ${data['phone'] ?? '-'}\n"
                            "Alamat: ${data['address'] ?? '-'}\n"
                            "Bergabung: ${joinedAt != null ? DateFormat('dd MMM yyyy, HH:mm').format((joinedAt as Timestamp).toDate()) : '-'}",
                            style: const TextStyle(color: Colors.white),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Tutup",
                                  style: TextStyle(
                                      color: Colors.cyanAccent)),
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
                              color: Colors.cyanAccent, size: 18),
                          SizedBox(width: 8),
                          Text("Detail",
                              style: TextStyle(color: Colors.white)),
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
                              style: TextStyle(color: Colors.white)),
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
