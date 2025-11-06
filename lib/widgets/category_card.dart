import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/wallpaper_model.dart';

class CategoryCard extends StatelessWidget {
  final WallpaperModel wallpaper;
  final VoidCallback onTap;
  final bool simplified;

  const CategoryCard({
    super.key,
    required this.wallpaper,
    required this.onTap,
    this.simplified = false,
  });

  @override
  Widget build(BuildContext context) {
    final subtitleText = wallpaper.tags.isNotEmpty
        ? wallpaper.tags.join(', ')
        : wallpaper.description; // ✅ use description if no tags

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: wallpaper.id,
              child: Image.asset(
                wallpaper.image,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(color: const Color(0xFFE6E6E6)),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.55),
                    Colors.transparent,
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
            if (!simplified)
              Positioned(
                top: 10,
                right: 10,
                child: Icon(
                  wallpaper.isFavourite
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: wallpaper.isFavourite
                      ? Colors.pinkAccent
                      : Colors.white70,
                  size: 22,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      wallpaper.category, // ✅ replaced name
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (!simplified && subtitleText.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        subtitleText,
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 12.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
