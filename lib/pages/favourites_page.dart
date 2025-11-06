import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/wallpaper_model.dart';
import '../widgets/wallpaper_card.dart';
import '../widgets/top_nav_button.dart';
import 'preview_page.dart';

class FavouritesPage extends StatefulWidget {
  const FavouritesPage({super.key});

  @override
  State<FavouritesPage> createState() => _FavouritesPageState();
}

class _FavouritesPageState extends State<FavouritesPage> {
  String _selectedRoute = '/favourites';

  final List<WallpaperModel> savedWallpapers = [
    WallpaperModel(
      id: 'fav1',
      category: 'Nature',
      image: 'assets/images/nature1.jpg',
      tags: ['Nature', 'Calm', 'Sunset'],
      description: 'A peaceful sunset over a lake surrounded by trees.',
      isFavourite: true,
    ),
    WallpaperModel(
      id: 'fav2',
      category: 'Nature',
      image: 'assets/images/nature2.jpg',
      tags: ['Nature', 'Warm', 'Landscape'],
      description: 'Rolling golden hills basking in the evening glow.',
      isFavourite: true,
    ),
    WallpaperModel(
      id: 'fav3',
      category: 'Urban',
      image: 'assets/images/urban.jpg',
      tags: ['City', 'Lights', 'Vibe'],
      description: 'Bright lights and night energy in the heart of the city.',
      isFavourite: true,
    ),
  ];

  void _onNavTap(String route) {
    if (_selectedRoute == route) return;
    setState(() => _selectedRoute = route);
    Navigator.pushNamed(context, route);
  }

  void _toggleFavourite(WallpaperModel wallpaper) {
    setState(() {
      wallpaper.isFavourite = !wallpaper.isFavourite;
      if (!wallpaper.isFavourite) {
        savedWallpapers.removeWhere((w) => w.id == wallpaper.id);
      }
    });
  }

  Future<void> _openPreview(WallpaperModel wallpaper) async {
    final updatedWallpaper = await Navigator.push<WallpaperModel>(
      context,
      MaterialPageRoute(
        builder: (_) => WallpaperPreviewPage(wallpaper: wallpaper),
      ),
    );

    if (updatedWallpaper != null) {
      setState(() {
        final index =
            savedWallpapers.indexWhere((w) => w.id == updatedWallpaper.id);

        // If it’s still favourite, update it
        if (updatedWallpaper.isFavourite) {
          if (index != -1) savedWallpapers[index] = updatedWallpaper;
        } else {
          // If unfavourited inside preview → remove from list
          if (index != -1) savedWallpapers.removeAt(index);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
              child: Row(
                children: [
                  // App Logo
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
                        icon: Icons.favorite,
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

            //  Main Content
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 28),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFFFFA726), Color(0xFFE91E63)],
                        ).createShader(bounds),
                        child: Text(
                          'Saved Wallpapers',
                          style: GoogleFonts.poppins(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your saved wallpaper collection',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: const Color(0xFF8D8D8D),
                        ),
                      ),
                      const SizedBox(height: 28),

                      //  Wallpaper Grid
                      LayoutBuilder(
                        builder: (context, constraints) {
                          int crossAxisCount = constraints.maxWidth ~/ 200;
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: savedWallpapers.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount.clamp(2, 5),
                              crossAxisSpacing: 20,
                              mainAxisSpacing: 20,
                              childAspectRatio: 0.75,
                            ),
                            itemBuilder: (context, index) {
                              final wallpaper = savedWallpapers[index];
                              return GestureDetector(
                                onTap: () => _openPreview(wallpaper),
                                child: WallpaperCard(
                                  wallpaper: wallpaper,
                                  onFavouriteToggle: () =>
                                      _toggleFavourite(wallpaper),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
