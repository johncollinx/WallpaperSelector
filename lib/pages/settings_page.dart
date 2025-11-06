import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  String _selectedQuality = 'High ( Best Quality )';
  String _selectedRoute = '/settings';
  bool _isMenuOpen = false; // for mobile menu toggle

  void _onNavTap(String route) {
    setState(() => _selectedRoute = route);
    // Example navigation logic:
    if (route != '/settings') Navigator.pushNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: Column(
          children: [
            // Responsive Header Navigation Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Color(0xFFE0E0E0), width: 0.8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // App logo + name
                  Row(
                    children: [
                      const Icon(Icons.diamond_rounded,
                          color: Color(0xFFFF7043), size: 22),
                      const SizedBox(width: 8),
                      Text(
                        "Wallpaper Studio",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF333333),
                        ),
                      ),
                    ],
                  ),

                  //  Desktop Nav Buttons or Mobile Menu
                  if (!isMobile)
                    Row(
                      children: [
                        _navButton(context, "Home", route: '/'),
                        const SizedBox(width: 16),
                        _navButton(context, "Browse", route: '/browse'),
                        const SizedBox(width: 16),
                        _navButton(context, "Favourites", route: '/favourites'),
                        const SizedBox(width: 16),
                        _navButton(context, "Settings",
                            route: '/settings', selected: true),
                      ],
                    )
                  else
                    // Hamburger menu icon
                    IconButton(
                      icon: Icon(
                        _isMenuOpen ? Icons.close : Icons.menu,
                        color: Colors.black87,
                      ),
                      onPressed: () =>
                          setState(() => _isMenuOpen = !_isMenuOpen),
                    ),
                ],
              ),
            ),

            // Mobile Dropdown Navigation
            if (_isMenuOpen && isMobile)
              Container(
                width: double.infinity,
                color: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _navButton(context, "Home", route: '/'),
                    _navButton(context, "Browse", route: '/browse'),
                    _navButton(context, "Favourites", route: '/favourites'),
                    _navButton(context, "Settings",
                        route: '/settings', selected: true),
                  ],
                ),
              ),

            // Page Body
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Text
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFFFFA726), Color(0xFFE91E63)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ).createShader(bounds),
                      child: Text(
                        'Settings',
                        style: GoogleFonts.poppins(
                          fontSize: 42,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Customize your Wallpaper Studio experience',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: const Color(0xFF626262),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Settings card
                    Center(
                      child: Container(
                        width: width > 700 ? 600 : double.infinity,
                        padding: const EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Wallpaper Setup',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Configure your wallpaper settings and enable auto-rotation',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: const Color(0xFF777777),
                              ),
                            ),
                            const SizedBox(height: 30),

                            // Image Quality Dropdown
                            Container(
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: const Color(0xFFE0E0E0)),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 6),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedQuality,
                                  isExpanded: true,
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'High ( Best Quality )',
                                      child: Text('High ( Best Quality )'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'Medium ( Standard )',
                                      child: Text('Medium ( Standard )'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'Low ( Battery Saver )',
                                      child: Text('Low ( Battery Saver )'),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    setState(() => _selectedQuality = value!);
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 25),

                            // Notification Toggle
                            Container(
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: const Color(0xFFE0E0E0)),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Notification',
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Get notified about new wallpapers and updates',
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          color: const Color(0xFF777777),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Switch(
                                    value: _notificationsEnabled,
                                    activeColor: const Color(0xFFFFAA00),
                                    onChanged: (val) {
                                      setState(
                                          () => _notificationsEnabled = val);
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 35),

                            // Buttons Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                        color: Color(0xFFE0E0E0)),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(30)),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 40, vertical: 14),
                                  ),
                                  onPressed: () {},
                                  child: Text(
                                    'Cancel',
                                    style: GoogleFonts.poppins(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFFAA00),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(30)),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 40, vertical: 14),
                                  ),
                                  onPressed: () {},
                                  child: Text(
                                    'Save Settings',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navButton(BuildContext context, String label,
      {bool selected = false, String? route}) {
    return TextButton(
      onPressed: () => _onNavTap(route ?? '/'),
      style: TextButton.styleFrom(
        foregroundColor: selected ? Colors.black : const Color(0xFF757575),
        backgroundColor:
            selected ? const Color(0xFFF1F1F1) : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
    );
  }
}
