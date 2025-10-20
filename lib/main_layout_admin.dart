import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'admin_page.dart';

class MainLayoutAdmin extends StatefulWidget {
  final String title;
  final Widget body;

  const MainLayoutAdmin({
    super.key,
    required this.title,
    required this.body,
  });

  @override
  State<MainLayoutAdmin> createState() => _MainLayoutAdminState();
}

class _MainLayoutAdminState extends State<MainLayoutAdmin> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    AdminPage(), // USERS
    Center(child: Text('Orders Page', style: TextStyle(color: Colors.white))),
    Center(child: Text('Reports Page', style: TextStyle(color: Colors.white))),
    Center(child: Text('Profile Page', style: TextStyle(color: Colors.white))),
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
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
              color: Colors.cyanAccent, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        bottom: true,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (Widget child, Animation<double> animation) {
            final offsetTween =
                Tween<Offset>(begin: const Offset(0.1, 0), end: Offset.zero);
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
          color: Colors.white.withOpacity(0.08),
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
                _buildNavItem(Icons.people, 'USERS', 0, activeColor,
                    inactiveColor, glowColor),
                _buildNavItem(Icons.local_laundry_service, 'ORDERS', 1,
                    activeColor, inactiveColor, glowColor),
                _buildNavItem(Icons.bar_chart, 'REPORT', 2, activeColor,
                    inactiveColor, glowColor),
                _buildNavItem(Icons.admin_panel_settings, 'PROFILE', 3,
                    activeColor, inactiveColor, glowColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index, Color activeColor,
      Color inactiveColor, Color glowColor) {
    final bool isActive = _selectedIndex == index;
    IconData effectiveIcon = icon;

    if (index == 0) {
      effectiveIcon = isActive ? Icons.people : Icons.people_outline;
    } else if (index == 3) {
      effectiveIcon = isActive
          ? Icons.admin_panel_settings
          : Icons.admin_panel_settings_outlined;
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
