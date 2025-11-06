import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/wallpaper_model.dart';

class WallpaperCard extends StatelessWidget {
  final WallpaperModel wallpaper;
  final VoidCallback onFavouriteToggle;

  const WallpaperCard({
    super.key,
    required this.wallpaper,
    required this.onFavouriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 🖼️ Wallpaper Image
          Image.asset(
            wallpaper.image,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Container(color: const Color(0xFFE6E6E6)),
          ),

          // 🌫️ Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.6),
                  Colors.transparent,
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),

          // Favourite Icon
          Positioned(
            top: 10,
            right: 10,
            child: GestureDetector(
              onTap: onFavouriteToggle,
              child: Icon(
                wallpaper.isFavourite
                    ? Icons.favorite
                    : Icons.favorite_border,
                color:
                    wallpaper.isFavourite ? Colors.pinkAccent : Colors.white70,
                size: 22,
              ),
            ),
          ),

          // 🏷️ Category + Description
          Positioned(
            bottom: 12,
            left: 12,
            right: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  wallpaper.category,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    shadows: const [
                      Shadow(
                          color: Colors.black54,
                          blurRadius: 6,
                          offset: Offset(1, 1))
                    ],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  wallpaper.description,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.white70,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
