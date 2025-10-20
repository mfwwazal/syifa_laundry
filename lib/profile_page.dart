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
  // ... (di dalam class _ProfilePageState)

// ...

// Hapus atau ganti _navigateToEditProfile dengan fungsi ini:
  void _showEditProfileSheet() {
    // Pastikan user dan userData tersedia
    if (user == null || userData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Data pengguna tidak tersedia.")),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Penting agar keyboard tidak menutupi input
      backgroundColor:
          Colors.transparent, // Agar background Container di bawah bisa muncul
      builder: (context) {
        return _EditProfileForm(
          initialData: userData!,
          userId: user!.uid,
          // Callback untuk me-refresh data di ProfilePage
          onProfileUpdated: () {
            _loadUserData();
          },
        );
      },
    );
  }

// ...

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

                        // --- Tombol Edit Profil ---
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
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
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: _showEditProfileSheet,
                              icon: const Icon(Icons.edit,
                                  color: Colors.cyanAccent, size: 24),
                              tooltip: 'Edit Profil',
                            )
                          ],
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
                              borderSide:
                                  const BorderSide(color: Colors.cyanAccent),
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
// Di file profile_page.dart

// Tambahkan kode ini di bagian bawah file, di luar class ProfilePage dan _ProfilePageState

class _EditProfileForm extends StatefulWidget {
  final Map<String, dynamic> initialData;
  final String userId;
  final VoidCallback onProfileUpdated;

  const _EditProfileForm({
    required this.initialData,
    required this.userId,
    required this.onProfileUpdated,
  });

  @override
  State<_EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<_EditProfileForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.initialData['name'] ?? '');
    _phoneController =
        TextEditingController(text: widget.initialData['phone'] ?? '');
    _addressController =
        TextEditingController(text: widget.initialData['address'] ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);

      try {
        final updatedData = {
          'name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'address': _addressController.text.trim(),
        };

        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .update(updatedData);

        widget
            .onProfileUpdated(); // Panggil callback untuk refresh data di ProfilePage

        if (mounted) {
          // Tutup bottom sheet
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Profil berhasil diperbarui!"),
              backgroundColor: Color(0xFF63B9C4), // Warna cyan
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Gagal menyimpan: $e"),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isSaving = false);
        }
      }
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.cyanAccent),
        prefixIcon: Icon(icon, color: Colors.cyanAccent),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.cyanAccent, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.cyanAccent.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.cyanAccent, width: 2),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color cyanLight = Color(0xFF63B9C4);

    return Container(
      padding: EdgeInsets.only(
        top: 30,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom +
            20, // Penting untuk keyboard
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF1A2A2E), // Warna yang lebih gelap untuk modal
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Edit Informasi Profil",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Input Nama
              _buildTextField(
                controller: _nameController,
                label: "Nama Lengkap",
                icon: Icons.person,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Nama wajib diisi.' : null,
              ),
              const SizedBox(height: 16),

              // Input Telepon
              _buildTextField(
                controller: _phoneController,
                label: "Nomor Telepon",
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              // Input Alamat
              _buildTextField(
                controller: _addressController,
                label: "Alamat Lengkap",
                icon: Icons.location_on,
                maxLines: 3,
              ),
              const SizedBox(height: 30),

              // Tombol Simpan
              ElevatedButton.icon(
                onPressed: _isSaving ? null : () => _saveProfile(context),
                icon: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : const Icon(Icons.save, color: Colors.black),
                label: Text(
                  _isSaving ? "Menyimpan..." : "Simpan Perubahan",
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: cyanLight,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
