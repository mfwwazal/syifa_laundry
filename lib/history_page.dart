import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  static const Color cyanLight = Color(0xFF86D5E0);
  static const Color cyanDark = Color(0xFF63B9C4);
  static const String fontFamily = 'Poppins';

  Stream<QuerySnapshot> _getSantriData() {
    return FirebaseFirestore.instance
        .collection('form_santri')
        .orderBy('date', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> _getMandiriData() {
    return FirebaseFirestore.instance
        .collection('laundry_mandiri')
        .orderBy('date', descending: true)
        .snapshots();
  }

  Widget _buildSection({
    required String title,
    required Color color,
    required Stream<QuerySnapshot> stream,
  }) {
    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child:
                Center(child: CircularProgressIndicator(color: Colors.white)),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Belum ada data $title.',
              style: const TextStyle(
                fontFamily: fontFamily,
                color: Colors.white70,
              ),
            ),
          );
        }

        final docs = snapshot.data!.docs;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: color.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(2, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    title == 'Santri'
                        ? Icons.person_outline
                        : Icons.local_laundry_service_outlined,
                    color: color,
                    size: 34,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['name'] ?? '-',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            fontFamily: fontFamily,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Kamar: ${data['room'] ?? '-'}',
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                            fontFamily: fontFamily,
                          ),
                        ),
                        Text(
                          'Jumlah: ${data['number_of_clothes'] ?? '-'}',
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                            fontFamily: fontFamily,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Pakaian: ${(data['types_of_clothes'] as List?)?.join(", ") ?? "-"}',
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 13,
                            fontFamily: fontFamily,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            data['date'] != null
                                ? (data['date'] as Timestamp)
                                    .toDate()
                                    .toString()
                                    .substring(0, 16)
                                : '-',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                              fontFamily: fontFamily,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // 🌑 dark theme background
      appBar: AppBar(
        backgroundColor: cyanDark,
        title: const Text(
          'Riwayat Pengisian',
          style: TextStyle(
            fontFamily: fontFamily,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevation: 4,
      ),
      body: SafeArea(child:
      SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Text(
                'Laundry Santri',
                style: TextStyle(
                  fontFamily: fontFamily,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            _buildSection(
              title: 'Santri',
              color: cyanDark,
              stream: _getSantriData(),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 25, 16, 8),
              child: Text(
                'Laundry Mandiri',
                style: TextStyle(
                  fontFamily: fontFamily,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            _buildSection(
              title: 'Mandiri',
              color: cyanLight,
              stream: _getMandiriData(),
            ),
            const SizedBox(height: 25),
          ],
        ),
      ),
      )
      
    );
  }
}
