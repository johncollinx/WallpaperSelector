// lib/widgets/wallpaper_card.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/wallpaper_model.dart';

class WallpaperCard extends StatelessWidget {
  final WallpaperModel wallpaper;
  final VoidCallback onFavouriteToggle;
  final VoidCallback? onTap;
  final bool isListView; // for browse list mode

  const WallpaperCard({
    super.key,
    required this.wallpaper,
    required this.onFavouriteToggle,
    this.onTap,
    this.isListView = false,
  });

  @override
  Widget build(BuildContext context) {
    final cardWidth = isListView ? 280.0 : 220.0;
    final cardHeight = isListView ? 140.0 : 300.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: cardWidth,
        height: cardHeight,
        margin: EdgeInsets.only(
          right: isListView ? 16 : 0,
          bottom: 22,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Wallpaper image
              Image.asset(
                wallpaper.image,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(color: const Color(0xFFE0E0E0)),
              ),

              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.6),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),

              // Top favourite icon
              Positioned(
                top: 12,
                right: 12,
                child: InkWell(
                  onTap: onFavouriteToggle,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: wallpaper.isFavourite
                          ? const Color(0xFFFFC107).withOpacity(0.9)
                          : Colors.white.withOpacity(0.25),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      wallpaper.isFavourite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),

              // Bottom info (category only)
              Positioned(
                left: 14,
                bottom: 14,
                right: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    wallpaper.category,
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
