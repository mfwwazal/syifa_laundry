import 'dart:ui'; // ✅ untuk efek blur
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'home_page.dart';
import 'history_page.dart';
import 'profile_page.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    HistoryPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    HapticFeedback.lightImpact();
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    const Color activeColor = Colors.white;
    const Color inactiveColor = Colors.white;
    const Color glowColor = Color(0xFF63B9C4);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        bottom: true,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (Widget child, Animation<double> animation) {
            final offsetTween = Tween<Offset>(
              begin: const Offset(0.1, 0),
              end: Offset.zero,
            );
            return SlideTransition(
              position: offsetTween.animate(
                CurvedAnimation(parent: animation, curve: Curves.easeInOut),
              ),
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          child: _widgetOptions[_selectedIndex],
        ),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(16),
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08), // ✅ transparan halus
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home_outlined, 'HOME', 0, activeColor, inactiveColor, glowColor),
                _buildNavItem(Icons.history, 'HISTORY', 1, activeColor, inactiveColor, glowColor),
                _buildNavItem(Icons.person_outline, 'PROFILE', 2, activeColor, inactiveColor, glowColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      IconData icon, String label, int index, Color activeColor, Color inactiveColor, Color glowColor) {
    final bool isActive = _selectedIndex == index;
    IconData effectiveIcon = icon;

    if (index == 0) {
      effectiveIcon = isActive ? Icons.home : Icons.home_outlined;
    } else if (index == 2) {
      effectiveIcon = isActive ? Icons.person : Icons.person_outline;
    }

    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: () => _onItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? Colors.white.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: glowColor.withOpacity(0.6),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              duration: const Duration(milliseconds: 250),
              scale: isActive ? 1.15 : 1.0,
              curve: Curves.easeOut,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 250),
                opacity: isActive ? 1 : 0.6,
                child: Icon(
                  effectiveIcon,
                  color: isActive ? activeColor : inactiveColor,
                  size: 30,
                ),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: isActive
                  ? Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        label,
                        style: TextStyle(
                          color: activeColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
