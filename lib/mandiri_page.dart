import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MandiriPage extends StatefulWidget {
  const MandiriPage({super.key});

  @override
  State<MandiriPage> createState() => _MandiriPageState();
}

class _MandiriPageState extends State<MandiriPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _roomController = TextEditingController();
  final _jumlahController = TextEditingController();

  final Map<String, bool> _clothesTypes = {
    'Baju Senin': false,
    'Celana Senin': false,
    'Baju Selasa': false,
    'Celana Selasa': false,
    'Baju Rabu': false,
    'Celana Rabu': false,
    'Baju Batik': false,
    'Celana Batik': false,
    'Baju Pramuka': false,
    'Celana Pramuka': false,
    'Gamis': false,
    'Baju Bebas': false,
    'Celana Bebas': false,
    'Sarung': false,
    'Handuk': false,
    'Sprei': false,
    'Selimut': false,
    'Lainnya': false,
  };

  bool _isLoading = false;

  void _updateJumlah() {
    final count = _clothesTypes.values.where((v) => v).length;
    _jumlahController.text = count.toString();
  }

  Future<void> _kirimData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final selectedClothes = _clothesTypes.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toList();

      await FirebaseFirestore.instance.collection('laundry_mandiri').add({
        'name': _namaController.text.trim(),
        'room': _roomController.text.trim(),
        'number_of_clothes': selectedClothes.length,
        'types_of_clothes': selectedClothes,
        'date': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Data laundry mandiri berhasil dikirim!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Gagal mengirim data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryCyan = Color(0xFF63B9C4);
    const Color backgroundDark = Color(0xFF0D1B1E);
    const Color lightCyan = Color(0xFF86D5E0);

    return Scaffold(
      backgroundColor: backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Laundry Mandiri',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Isi data laundry mandiri dengan lengkap",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _namaController,
                      label: "Nama Lengkap",
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 15),
                    _buildDropdownField(
                      controller: _roomController,
                      label: 'Nomor Kamar',
                      icon: Icons.home,
                      items: const [
                        '11.01',
                        '11.02',
                        '11.03',
                        '11.04',
                      ],
                    ),
                    const SizedBox(height: 15),
                    _buildTextField(
                      controller: _jumlahController,
                      label: "Jumlah Pakaian (otomatis)",
                      icon: Icons.numbers,
                      readOnly: true,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Pilih Jenis Pakaian:",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Column(
                      children: _clothesTypes.keys.map((type) {
                        return Theme(
                          data: ThemeData(unselectedWidgetColor: lightCyan),
                          child: CheckboxListTile(
                            title: Text(
                              type,
                              style: const TextStyle(color: Colors.white70),
                            ),
                            activeColor: primaryCyan,
                            checkColor: Colors.black,
                            value: _clothesTypes[type],
                            onChanged: (val) {
                              setState(() {
                                _clothesTypes[type] = val!;
                                _updateJumlah();
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryCyan,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _isLoading ? null : _kirimData,
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.black,
                              )
                            : const Text(
                                'Kirim Data Laundry',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool readOnly = false,
  }) {
    const Color primaryCyan = Color(0xFF63B9C4);
    const Color lightCyan = Color(0xFF86D5E0);

    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: lightCyan),
        filled: true,
        fillColor: const Color(0xFF14292E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryCyan.withOpacity(0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryCyan.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: lightCyan, width: 1.5),
        ),
      ),
      validator: (value) =>
          !readOnly && (value == null || value.isEmpty) ? 'Wajib diisi' : null,
    );
  }

  Widget _buildDropdownField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required List<String> items,
  }) {
    const Color primaryCyan = Color(0xFF63B9C4);
    const Color lightCyan = Color(0xFF86D5E0);

    String? selectedValue = controller.text.isNotEmpty ? controller.text : null;

    return StatefulBuilder(
      builder: (context, setState) {
        return DropdownButtonFormField<String>(
          value: selectedValue,
          dropdownColor: const Color(0xFF14292E),
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Colors.white70),
            prefixIcon: Icon(icon, color: lightCyan),
            filled: true,
            fillColor: const Color(0xFF14292E),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryCyan.withOpacity(0.5)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryCyan.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: lightCyan, width: 1.5),
            ),
          ),
          items: items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: const TextStyle(color: Colors.white)),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedValue = value;
              controller.text = value ?? '';
            });
          },
          validator: (value) =>
              (value == null || value.isEmpty) ? 'Pilih nomor kamar' : null,
        );
      },
    );
  }
}
