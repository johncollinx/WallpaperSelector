import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/hero_section.dart';
import '../widgets/top_nav_button.dart';
import '../models/wallpaper_model.dart';
import '../pages/preview_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _selectedRoute = '/';

  final List<WallpaperModel> wallpapers = [
    WallpaperModel(
      id: '1',
      name: 'Sunset Bliss',
      category: 'Nature',
      image: 'assets/images/nature.png',
      tags: ['Nature', 'Sunset', 'Warm'],
      description: 'Mountains, forest and landscape.',
    ),
    WallpaperModel(
      id: '2',
      name: 'Urban Lights',
      category: 'Abstract',
      image: 'assets/images/abstract.jpg',
      tags: ['City', 'Nightlife', 'Lights'],
      description: 'Modern geometric and artistic designs.',
    ),
    WallpaperModel(
      id: '3',
      name: 'Forest Path',
      category: 'Urban',
      image: 'assets/images/urban.jpg',
      tags: ['Nature', 'Forest', 'Pathway'],
      description: 'Cities, architecture and street scenes.',
    ),
    WallpaperModel(
      id: '4',
      name: 'Cosmic Wonder',
      category: 'Space',
      image: 'assets/images/space.jpg',
      tags: ['Planets', 'Galaxies', 'Stars'],
      description: 'Cosmos, planets and galaxies.',
    ),
    WallpaperModel(
      id: '5',
      name: 'Minimalist Design',
      category: 'Minimalist',
      image: 'assets/images/minimalist.jpg',
      tags: ['Clean', 'Simple', 'Elegant'],
      description: 'Clean, simple and elegant designs.',
    ),
    WallpaperModel(
      id: '6',
      name: 'Wildlife',
      category: 'Animals',
      image: 'assets/images/animal.jpg',
      tags: ['Wildlife', 'Nature', 'Photography'],
      description: 'Wildlife and nature photography.',
    ),
  ];

  void _onNavTap(String route) {
    if (_selectedRoute == route) return;
    setState(() => _selectedRoute = route);
    Navigator.pushNamed(context, route);
  }

  void _openWallpaper(WallpaperModel wallpaper) async {
    final updatedWallpaper = await Navigator.push<WallpaperModel>(
      context,
      MaterialPageRoute(
        builder: (_) => WallpaperPreviewPage(wallpaper: wallpaper),
      ),
    );

    if (updatedWallpaper != null) {
      setState(() {
        final index = wallpapers.indexWhere((w) => w.id == updatedWallpaper.id);
        if (index != -1) wallpapers[index] = updatedWallpaper;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          final maxWidth = constraints.maxWidth;
          final isWide = maxWidth > 900;

          return Column(
            children: [
              // Top Navigation
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
                child: Row(
                  children: [
                    // Logo
                    Row(
                      children: [
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFA726), Color(0xFFE91E63)],
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Wallpaper Studio',
                          style: GoogleFonts.poppins(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Navigation
                    Row(
                      children: [
                        TopNavButton(
                          icon: Icons.home_outlined,
                          label: 'Home',
                          selected: _selectedRoute == '/',
                          onTap: () => _onNavTap('/'),
                        ),
                        const SizedBox(width: 12),
                        TopNavButton(
                          icon: Icons.grid_view,
                          label: 'Browse',
                          selected: _selectedRoute == '/browse',
                          onTap: () => _onNavTap('/browse'),
                        ),
                        const SizedBox(width: 12),
                        TopNavButton(
                          icon: Icons.favorite_border,
                          label: 'Favourites',
                          selected: _selectedRoute == '/favourites',
                          onTap: () => _onNavTap('/favourites'),
                        ),
                        const SizedBox(width: 12),
                        TopNavButton(
                          icon: Icons.settings_outlined,
                          label: 'Settings',
                          selected: _selectedRoute == '/settings',
                          onTap: () => _onNavTap('/settings'),
                        ),
                      ],
                    )
                  ],
                ),
              ),

              const Divider(height: 1, thickness: 1, color: Color(0xFFECECEC)),

              // Page Body
              Expanded(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 28),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        HeroSection(isWide: isWide),
                        const SizedBox(height: 30),
                        // Categories Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Categories',
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold, fontSize: 22),
                            ),
                            TextButton(
                                onPressed: () =>
                                    Navigator.pushNamed(context, '/browse'),
                                child: const Text('See All')),
                          ],
                        ),
                        const SizedBox(height: 18),
                        // Categories Grid with counts and gradient overlay
                        Wrap(
                          spacing: 20,
                          runSpacing: 20,
                          children: [
                            _buildCategoryCard(
                                title: 'Nature',
                                subtitle: 'Mountains and Landscapes',
                                count: wallpapers
                                    .where((w) => w.category == 'Nature')
                                    .length,
                                image: 'assets/images/nature.jpg'),
                            _buildCategoryCard(
                                title: 'Abstract',
                                subtitle: 'Geometric and artistic',
                                count: wallpapers
                                    .where((w) => w.category == 'Abstract')
                                    .length,
                                image: 'assets/images/abstract.jpg'),
                            _buildCategoryCard(
                                title: 'Urban',
                                subtitle: 'Cities and architecture',
                                count: wallpapers
                                    .where((w) => w.category == 'Urban')
                                    .length,
                                image: 'assets/images/urban.jpg'),
                            _buildCategoryCard(
                                title: 'Space',
                                subtitle: 'Planets and galaxies',
                                count: wallpapers
                                    .where((w) => w.category == 'Space')
                                    .length,
                                image: 'assets/images/space.jpg'),
                          ],
                        ),
                        const SizedBox(height: 30),
                        // Optionally show featured wallpapers here
                      ],
                    ),
                  ),
                ),
              )
            ],
          );
        }),
      ),
    );
  }

  Widget _buildCategoryCard({
    required String title,
    required String subtitle,
    required int count,
    required String image,
  }) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/browse', arguments: title),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(image, fit: BoxFit.cover),
            Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              )),
            ),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(subtitle,
                        style: GoogleFonts.poppins(
                            color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Text('$count wallpapers',
                          style: GoogleFonts.poppins(
                              color: Colors.white, fontSize: 12)),
                    )
                  ]),
            )
          ],
        ),
      ),
    );
  }
}
