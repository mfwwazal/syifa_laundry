import 'package:flutter/material.dart';
import 'mandiri_page.dart';
import 'form_santri_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const Color primaryCyan = Color(0xFF63B9C4);
  static const Color lightCyan = Color(0xFF86D5E0);
  static const Color backgroundDark = Color(0xFF0D1B1E);
  static const String fontFamily = 'Poppins';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1B2E35), Colors.black],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 App Bar Custom
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 20),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.asset(
                        '../assets/images/logo_smk.png',
                        width: 38,
                        height: 38,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 38,
                          height: 38,
                          color: primaryCyan,
                          child: const Icon(Icons.school,
                              color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Smkit.assyifa',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        fontFamily: fontFamily,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.notifications_none,
                          color: Colors.white70, size: 28),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),

              // 🔹 Banner
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    Image.asset(
                      '../assets/images/banner.png',
                      width: double.infinity,
                      height: 220,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 220,
                          color: Colors.grey[800],
                          child: const Center(
                            child: Text(
                              'Banner Laundry',
                              style: TextStyle(
                                fontFamily: fontFamily,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    Container(
                      height: 220,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.4),
                            Colors.transparent
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ),
                    const Positioned(
                      left: 18,
                      bottom: 18,
                      right: 18,
                      child: Text(
                        'Laundry hari ini akan lebih cepat selesai, jangan lupa ambil tepat waktu!',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          fontFamily: fontFamily,
                          height: 1.4,
                          shadows: [
                            Shadow(
                              blurRadius: 3.0,
                              color: Colors.black,
                              offset: Offset(1.0, 1.0),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                'Layanan Laundry',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontFamily: fontFamily,
                ),
              ),
              const SizedBox(height: 15),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildServiceCard(
                      context, Icons.person_outline, 'Form Santri', primaryCyan),
                  _buildServiceCard(context, Icons.local_laundry_service_outlined,
                      'Mandiri', lightCyan),
                ],
              ),

              const SizedBox(height: 40),

              Align(
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Icon(Icons.local_shipping_outlined,
                        color: lightCyan, size: 32),
                    const SizedBox(height: 8),
                    Text(
                      'Antar - Jemput Cepat',
                      style: TextStyle(
                        fontFamily: fontFamily,
                        fontSize: 14,
                        color: Colors.white70,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 80), // biar ga ketiban navbar
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard(
      BuildContext context, IconData icon, String label, Color color) {
    return InkWell(
      onTap: () {
        if (label == 'Form Santri') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FormSantriPage()),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MandiriPage()),
          );
        }
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 155,
        height: 165,
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
          color: Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.25),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 58, color: color),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                fontFamily: fontFamily,
                fontWeight: FontWeight.w500,
                fontSize: 15,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
