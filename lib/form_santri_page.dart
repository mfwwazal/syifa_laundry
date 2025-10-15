import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FormSantriPage extends StatefulWidget {
  const FormSantriPage({super.key});

  @override
  State<FormSantriPage> createState() => _FormSantriPageState();
}

class _FormSantriPageState extends State<FormSantriPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _roomController = TextEditingController();
  final TextEditingController _jumlahController = TextEditingController();

  final List<String> _jenisPakaian = [
    "Baju Senin",
    "Celana Senin",
    "Baju Selasa",
    "Celana Selasa",
    "Baju Rabu",
    "Celana Rabu",
    "Baju Batik",
    "Celana Batik",
    "Gamis",
    "Baju Pramuka",
    "Celana Pramuka",
    "Baju Bebas",
    "Celana Bebas",
    "Sarung",
    "Handuk",
    "Sprei",
    "Selimut",
    "Lainnya"
  ];

  final List<String> _selectedTypes = [];
  bool _isLoading = false;

  /// 🔢 Fungsi hitung otomatis jumlah pakaian
  void _updateJumlahOtomatis() {
    _jumlahController.text = _selectedTypes.length.toString();
  }

  Future<void> _kirimData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('form_santri').add({
        'name': _namaController.text.trim(),
        'room': _roomController.text.trim(),
        'number_of_clothes': _selectedTypes.length, // ✅ otomatis
        'types_of_clothes': _selectedTypes,
        'date': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Data santri berhasil dikirim!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Gagal mengirim data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryCyan = Color(0xFF63B9C4);
    const Color backgroundDark = Color(0xFF0D1B1E);
    const Color surfaceDark = Color(0xFF13292E);

    return Scaffold(
      backgroundColor: backgroundDark,
      appBar: AppBar(
        title: const Text(
          'Form Laundry Santri',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: primaryCyan,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: surfaceDark.withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: primaryCyan.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Isi data laundry santri dengan lengkap",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),

                _buildInputField(
                  controller: _namaController,
                  label: 'Nama Santri',
                  icon: Icons.person,
                ),
                const SizedBox(height: 15),

                _buildInputField(
                  controller: _roomController,
                  label: 'Nomor Kamar',
                  icon: Icons.home,
                ),
                const SizedBox(height: 15),

                // Jumlah Pakaian (otomatis & non-editable)
                TextFormField(
                  controller: _jumlahController,
                  readOnly: true, // ✅ biar gak bisa diedit
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Jumlah Pakaian (otomatis)',
                    labelStyle: const TextStyle(color: Colors.white70),
                    prefixIcon:
                        const Icon(Icons.numbers, color: primaryCyan),
                    filled: true,
                    fillColor: const Color(0xFF1C3A40),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                const Text(
                  "Pilih Jenis Pakaian:",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),

                // Checkbox list
                ..._jenisPakaian.map((jenis) {
                  final selected = _selectedTypes.contains(jenis);
                  return Card(
                    color: selected
                        ? primaryCyan.withOpacity(0.2)
                        : Colors.transparent,
                    child: CheckboxListTile(
                      activeColor: primaryCyan,
                      checkColor: Colors.white,
                      title: Text(
                        jenis,
                        style: TextStyle(
                          color: selected ? primaryCyan : Colors.white70,
                          fontWeight: selected ? FontWeight.bold : null,
                        ),
                      ),
                      value: selected,
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            _selectedTypes.add(jenis);
                          } else {
                            _selectedTypes.remove(jenis);
                          }
                          _updateJumlahOtomatis(); // ✅ update otomatis
                        });
                      },
                    ),
                  );
                }).toList(),

                const SizedBox(height: 25),

                // Tombol kirim
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryCyan,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      shadowColor: primaryCyan.withOpacity(0.4),
                      elevation: 6,
                    ),
                    onPressed: _isLoading ? null : _kirimData,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Kirim Data',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isNumber = false,
  }) {
    const Color primaryCyan = Color(0xFF63B9C4);
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: primaryCyan),
        filled: true,
        fillColor: const Color(0xFF1C3A40),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) => value!.isEmpty ? '$label wajib diisi' : null,
    );
  }
}
