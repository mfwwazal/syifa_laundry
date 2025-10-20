import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syifa_laundry/home_page.dart';
import 'package:syifa_laundry/welcome_page.dart';
import 'package:intl/intl.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  User? user;
  Map<String, dynamic>? userData;
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  bool _isLoading = true;

  final TextEditingController _adminCodeCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final customerId = prefs.getString('customerId');
    final currentUser = FirebaseAuth.instance.currentUser;

    String? uid = currentUser?.uid ?? customerId;
    if (uid == null) {
      setState(() => _isLoading = false);
      return;
    }

    final snapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (snapshot.exists) {
      userData = snapshot.data();
    }

    setState(() {
      user = currentUser;
      _isLoading = false;
    });
    _controller.forward();
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('customerId');

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const WelcomePage()),
        (route) => false,
      );
    }
  }

  /// ✅ Verifikasi kode admin untuk upgrade role
  Future<void> _verifyAdminCode() async {
    const validCode = "Fawwaz Ganteng";
    final code = _adminCodeCtrl.text.trim();

    if (code != validCode) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Kode salah. Tidak ada perubahan."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .set({'role': 'admin'}, SetOptions(merge: true));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Kode valid! Anda sekarang adalah ADMIN."),
        backgroundColor: Colors.greenAccent,
      ),
    );

    await _loadUserData();
    _adminCodeCtrl.clear();
  }

  /// 🔄 Ganti role antara admin dan user
  Future<void> _changeRole() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final currentRole = userData?['role'] ?? 'user';
    final newRole = currentRole == 'admin' ? 'user' : 'admin';

    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .update({'role': newRole});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Role diubah menjadi: $newRole"),
        backgroundColor: Colors.cyan,
      ),
    );

    await _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    const Color cyanLight = Color(0xFF63B9C4);

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B1E),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.cyanAccent),
            )
          : FadeTransition(
              opacity: _fadeAnim,
              child: SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 80),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        CircleAvatar(
                          radius: 55,
                          backgroundColor: cyanLight,
                          child: const Icon(Icons.person,
                              size: 70, color: Colors.black),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          userData?['name'] ??
                              user?.email?.split('@')[0] ??
                              'Unknown User',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          user?.email ?? 'No Email',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 30),

                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(16),
                            border:
                                Border.all(color: cyanLight.withOpacity(0.3)),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _infoRow(Icons.phone, "Phone",
                                  userData?['phone'] ?? "-"),
                              _infoRow(Icons.location_on, "Address",
                                  userData?['address'] ?? "-"),
                              _infoRow(
                                Icons.calendar_today,
                                "Joined At",
                                userData?['joinedAt'] != null
                                    ? DateFormat('dd MMM yyyy, HH:mm').format(
                                        (userData!['joinedAt'] as Timestamp)
                                            .toDate())
                                    : "-",
                              ),
                              _infoRow(Icons.verified_user, "Role",
                                  userData?['role'] ?? "user"),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        /// 🔹 Tombol ganti role (hanya tampil jika role = admin)
                        if (userData?['role'] == 'admin')
                          ElevatedButton.icon(
                            onPressed: _changeRole,
                            icon: const Icon(Icons.switch_account,
                                color: Colors.black),
                            label: Text(
                              userData?['role'] == 'admin'
                                  ? "Turunkan jadi USER"
                                  : "Naikkan jadi ADMIN",
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amberAccent,
                              minimumSize: const Size(double.infinity, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),

                        const SizedBox(height: 16),

                        /// 🧩 Input kode admin
                        TextField(
                          controller: _adminCodeCtrl,
                          decoration: InputDecoration(
                            hintText: "Masukkan kode admin...",
                            hintStyle: const TextStyle(color: Colors.white54),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                  color: Colors.cyanAccent),
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: _verifyAdminCode,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.greenAccent,
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            "Verifikasi Kode Admin",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        /// 🚪 Tombol Logout
                        ElevatedButton.icon(
                          onPressed: _logout,
                          icon: const Icon(Icons.logout, color: Colors.black),
                          label: const Text(
                            "Logout",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.cyanAccent, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "$label:",
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
