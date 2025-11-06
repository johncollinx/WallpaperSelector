import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/wallpaper_model.dart';

class CategoriesGrid extends StatelessWidget {
  final List<WallpaperModel> wallpapers;
  final bool isGridView;
  final double maxWidth;
  final void Function(WallpaperModel) onTap;

  const CategoriesGrid({
    required this.wallpapers,
    required this.isGridView,
    required this.maxWidth,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = maxWidth > 900 ? 4 : 2;

    if (isGridView) {
      // 🟦 GRID MODE
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: wallpapers.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        itemBuilder: (context, index) {
          final wallpaper = wallpapers[index];
          return GestureDetector(
            onTap: () => onTap(wallpaper),
            child: Stack(
              children: [
                Hero(
                  tag: wallpaper.id,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      wallpaper.image,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.black87, Colors.transparent],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 12,
                  right: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        wallpaper.category, // ✅ replaced name
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          shadows: const [
                            Shadow(
                              color: Colors.black54,
                              blurRadius: 6,
                              offset: Offset(1, 1),
                            )
                          ],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        wallpaper.description,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.white60,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
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
              ],
            ),
          );
        },
      );
    } else {
      // 🟨 LIST MODE
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: wallpapers.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final wallpaper = wallpapers[index];
          return GestureDetector(
            onTap: () => onTap(wallpaper),
            child: Container(
              height: 130,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Hero(
                    tag: wallpaper.id,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.asset(
                        wallpaper.image,
                        width: 160,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            wallpaper.category, // ✅ replaced name
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            wallpaper.description,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.black45,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Icon(
                      wallpaper.isFavourite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: wallpaper.isFavourite
                          ? Colors.pinkAccent
                          : Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }
}
