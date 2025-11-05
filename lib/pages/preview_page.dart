import 'dart:io';

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_fonts/google_fonts.dart';
import 'package:win32/win32.dart';
import '../models/wallpaper_model.dart';

class WallpaperPreviewPage extends StatefulWidget {
  final WallpaperModel wallpaper;

  const WallpaperPreviewPage({super.key, required this.wallpaper});

  @override
  State<WallpaperPreviewPage> createState() => _WallpaperPreviewPageState();
}

class _WallpaperPreviewPageState extends State<WallpaperPreviewPage> {
  late List<WallpaperModel> wallpapers;
  late int selectedIndex;

  @override
  void initState() {
    super.initState();
    wallpapers = [
      WallpaperModel(
        id: 'w1',
        name: 'Nature 1',
        category: 'Nature',
        image: 'assets/images/nature1.jpg',
        tags: ['Nature', 'Ambience', 'Flowers'],
        description:
            'Discover the pure beauty of “Natural Essence” – your gateway to authentic, nature-inspired experiences.',
      ),
      WallpaperModel(
        id: 'w2',
        name: 'Nature 2',
        category: 'Nature',
        image: 'assets/images/nature2.jpg',
        tags: ['Mountains', 'Calm', 'Valley'],
        description: 'Experience serenity with breathtaking mountain views.',
      ),
      WallpaperModel(
        id: 'w3',
        name: 'Nature 3',
        category: 'Nature',
        image: 'assets/images/nature3.jpg',
        tags: ['Autumn', 'Forest', 'Leaves'],
        description: 'Immerse yourself in the warm hues of autumn foliage.',
      ),
      WallpaperModel(
        id: 'w4',
        name: 'Nature 4',
        category: 'Nature',
        image: 'assets/images/nature4.jpg',
        tags: ['Sky', 'Clouds', 'Sunset'],
        description: 'Capture the peaceful tones of sunset above the clouds.',
      ),
      WallpaperModel(
        id: 'w5',
        name: 'Nature 5',
        category: 'Nature',
        image: 'assets/images/nature5.png',
        tags: ['Stars', 'Night', 'Calm'],
        description: 'Lose yourself in the quiet beauty of a starlit night.',
      ),
      WallpaperModel(
        id: 'w6',
        name: 'Nature 6',
        category: 'Nature',
        image: 'assets/images/nature6.jpg',
        tags: ['Ocean', 'Rocks', 'Waves'],
        description: 'Embrace the soothing power of the ocean waves.',
      ),
    ];

    selectedIndex = wallpapers.indexWhere((w) => w.id == widget.wallpaper.id);
    if (selectedIndex == -1) selectedIndex = 0;
  }

  /// 🧩 Helper: copy asset to a temp file so Windows can access it
  Future<String> _copyAssetToFile(String assetPath) async {
    final byteData = await rootBundle.load(assetPath);
    final file = File('${Directory.systemTemp.path}/temp_wallpaper.jpg');
    await file.writeAsBytes(byteData.buffer.asUint8List());
    print('Wallpaper saved at: ${file.path}');
    return file.path;
  }

  /// 🧩 Helper: set wallpaper using Win32 API (direct system call)
  Future<void> _setWallpaperWindows(String imagePath) async {
    final pathPtr = TEXT(imagePath);
    final result = SystemParametersInfo(
      SPI_SETDESKWALLPAPER,
      0,
      pathPtr,
      SPIF_UPDATEINIFILE | SPIF_SENDCHANGE,
    );
    free(pathPtr);

    if (result == 0) {
      throw Exception('Failed to set wallpaper via Win32 API');
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = wallpapers[selectedIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Wallpaper Preview',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Row(
        children: [
          // Left: grid of wallpapers
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: GridView.builder(
                itemCount: wallpapers.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  childAspectRatio: 0.7,
                ),
                itemBuilder: (context, index) {
                  final wall = wallpapers[index];
                  final isSelected = selectedIndex == index;

                  return GestureDetector(
                    onTap: () => setState(() => selectedIndex = index),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            wall.image,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.black26,
                          ),
                        ),
                        Positioned(
                          bottom: 12,
                          left: 12,
                          child: Text(
                            wall.name,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Icon(
                            wall.isFavourite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color:
                                wall.isFavourite ? Colors.amber : Colors.white,
                          ),
                        ),
                        if (isSelected)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border:
                                    Border.all(color: Colors.amber, width: 3),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          // Right: details + action
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(30),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(-3, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Preview',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      )),
                  const SizedBox(height: 20),
                  Center(
                    child: Container(
                      width: 220,
                      height: 180,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.black12, width: 2),
                        image: DecorationImage(
                          image: AssetImage(selected.image),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Text(selected.name,
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600, fontSize: 20)),
                  const SizedBox(height: 10),
                  Text(selected.category,
                      style: GoogleFonts.poppins(
                          fontSize: 14, color: Colors.grey[600])),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 8,
                    children: selected.tags.map((t) => _buildTag(t)).toList(),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        selected.description,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            setState(() => selected.toggleFavourite());
                          },
                          icon: Icon(
                            selected.isFavourite
                                ? Icons.favorite
                                : Icons.favorite_border,
                          ),
                          label: Text(selected.isFavourite
                              ? 'Remove Favourite'
                              : 'Save to Favourites'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            try {
                              if (Platform.isWindows) {
                                final path =
                                    await _copyAssetToFile(selected.image);
                                await _setWallpaperWindows(path);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Wallpaper applied successfully!'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'This feature only works on Windows.'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to set wallpaper: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFB23F),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Set to Wallpaper',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                            ),
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
    );
  }

  Widget _buildTag(String text) {
    return Chip(
      label: Text(
        text,
        style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87),
      ),
      backgroundColor: const Color(0xFFEDEDED),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
    );
  }
}

