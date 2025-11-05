import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/categories_grid.dart';
import '../widgets/top_nav_button.dart';
import '../widgets/hero_section_browse.dart';
import '../models/wallpaper_model.dart';
import 'preview_page.dart';

class BrowseCategoryPage extends StatefulWidget {
  const BrowseCategoryPage({super.key});

  @override
  State<BrowseCategoryPage> createState() => _BrowseCategoryPageState();
}

class _BrowseCategoryPageState extends State<BrowseCategoryPage> {
  String _selectedRoute = '/browse';
  bool _isGridView = true;

  final List<WallpaperModel> wallpapers = [
    WallpaperModel(
      id: '1',
      // name: 'Sunset Bliss'
      category: 'Nature',
      image: 'assets/images/nature.png',
      tags: ['Nature', 'Sunset', 'Warm'],
      description: 'Mountains,forest and landscape.',
    ),
    WallpaperModel(
      id: '2',
      // name: 'Urban Lights',
      category: 'Abstract',
      image: 'assets/images/abstract.jpg',
      tags: ['City', 'Nightlife', 'Lights'],
      description: 'Modern Geometric and artistic designs.',
    ),
    WallpaperModel(
      id: '3',
      // name: 'Forest Path',
      category: 'Urban',
      image: 'assets/images/urban.jpg',
      tags: ['Nature', 'Forest', 'Pathway'],
      description: 'Cities,architecture and street.',
    ),
     WallpaperModel(
      id: '4',
      // name: 'Forest Path',
      category: 'Space',
      image: 'assets/images/space.jpg',
      tags: ['Nature', 'Forest', 'Pathway'],
      description: 'Cosmos, planets and galaxies.',
    ),
     WallpaperModel(
      id: '5',
      // name: 'Forest Path',
      category: 'Minimalist',
      image: 'assets/images/minimalist.jpg',
      tags: ['Nature', 'Forest', 'Pathway'],
      description: 'Clean, simple and elegant.',
    ),
     WallpaperModel(
      id: '6',
      // name: 'Forest Path',
      category: 'Animals',
      image: 'assets/images/animal.jpg',
      tags: ['Nature', 'Forest', 'Pathway'],
      description: 'Wildlife and nature photography.',
    ),
  ];

  void _onNavTap(String route) {
    if (_selectedRoute == route) return;
    setState(() => _selectedRoute = route);
    Navigator.pushNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          final maxWidth = constraints.maxWidth;

          return Column(
            children: [
              // 🧭 Top Navigation
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
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),

                    // Navigation Buttons
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
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, thickness: 1, color: Color(0xFFECECEC)),

              // 📜 Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 28),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        HeroSection(isWide: maxWidth > 900),
                        const SizedBox(height: 30),

                        // Title + Toggle
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Browse Categories',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            ),
                            IconButton(
                              tooltip: _isGridView
                                  ? 'Switch to List View'
                                  : 'Switch to Grid View',
                              icon: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: Icon(
                                  _isGridView
                                      ? Icons.view_list_rounded
                                      : Icons.grid_view_rounded,
                                  key: ValueKey(_isGridView),
                                ),
                              ),
                              onPressed: () =>
                                  setState(() => _isGridView = !_isGridView),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        // 🧩 Wallpaper Grid/List
                        CategoriesGrid(
                          wallpapers: wallpapers,
                          isGridView: _isGridView,
                          maxWidth: maxWidth,
                          onTap: (wallpaper) async {
                            final updatedWallpaper =
                                await Navigator.push<WallpaperModel>(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    WallpaperPreviewPage(wallpaper: wallpaper),
                              ),
                            );

                            if (updatedWallpaper != null) {
                              setState(() {
                                final index = wallpapers.indexWhere(
                                    (w) => w.id == updatedWallpaper.id);
                                if (index != -1) {
                                  wallpapers[index] = updatedWallpaper;
                                }
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
