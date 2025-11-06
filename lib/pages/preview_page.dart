import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_fonts/google_fonts.dart';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart' as win32;
import 'package:image/image.dart' as img;
import '../models/wallpaper_model.dart';

const int SPI_SETDESKWALLPAPER = 20;
const int SPIF_UPDATEINIFILE = 0x01;
const int SPIF_SENDCHANGE = 0x02;

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
        category: 'Nature',
        image: 'assets/images/nature1.jpg',
        tags: ['Nature', 'Ambience', 'Flowers'],
        description: 'Discover the pure beauty of “Natural Essence”.',
      ),
      WallpaperModel(
        id: 'w2',
        category: 'Nature',
        image: 'assets/images/nature2.jpg',
        tags: ['Mountains', 'Calm', 'Valley'],
        description: 'Experience serenity with breathtaking mountain views.',
      ),
      WallpaperModel(
        id: 'w3',
        category: 'Nature',
        image: 'assets/images/nature3.jpg',
        tags: ['Autumn', 'Forest', 'Leaves'],
        description: 'Immerse yourself in the warm hues of autumn foliage.',
      ),
      WallpaperModel(
        id: 'w4',
        category: 'Nature',
        image: 'assets/images/nature4.jpg',
        tags: ['Sky', 'Clouds', 'Sunset'],
        description: 'Capture peaceful tones of sunset above the clouds.',
      ),
    ];

    selectedIndex = wallpapers.indexWhere((w) => w.id == widget.wallpaper.id);
    if (selectedIndex == -1) selectedIndex = 0;
  }

  // 🧩 Prepare wallpaper and resize for Windows screen dimensions
  Future<String> _prepareWallpaper(String assetPath) async {
    if (!Platform.isWindows) {
      throw Exception('Wallpaper setting only supported on Windows.');
    }

    final byteData = await rootBundle.load(assetPath);
    final bytes = byteData.buffer.asUint8List();
    final original = img.decodeImage(bytes);
    if (original == null) throw Exception('Failed to decode image');

    final width = win32.GetSystemMetrics(win32.SM_CXSCREEN);
    final height = win32.GetSystemMetrics(win32.SM_CYSCREEN);
    final scale = max(width / original.width, height / original.height);

    final resized = img.copyResize(
      original,
      width: (original.width * scale).round(),
      height: (original.height * scale).round(),
    );

    final file = File('${Directory.systemTemp.path}/temp_wallpaper.jpg');
    await file.writeAsBytes(img.encodeJpg(resized, quality: 95));
    return file.path;
  }

  // 🖥️ Apply wallpaper using Win32 SystemParametersInfoW
  Future<void> _setWallpaperWindows(String imagePath) async {
    final pathPtr = imagePath.toNativeUtf16();
    final result = win32.SystemParametersInfoW(
      SPI_SETDESKWALLPAPER,
      0,
      pathPtr,
      SPIF_UPDATEINIFILE | SPIF_SENDCHANGE,
    );
    calloc.free(pathPtr);

    if (result == 0) {
      final errorCode = win32.GetLastError();
      throw Exception('Failed to set wallpaper (Error $errorCode)');
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
        title: Text('Wallpaper Preview',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600, color: Colors.black)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 1000;
          return isCompact
              ? _buildVerticalLayout(selected)
              : _buildHorizontalLayout(selected);
        },
      ),
    );
  }

  Widget _buildHorizontalLayout(WallpaperModel selected) {
    return Row(
      children: [
        Expanded(flex: 2, child: _buildWallpaperGrid()),
        Expanded(flex: 3, child: _buildDetailsPanel(selected)),
      ],
    );
  }

  Widget _buildVerticalLayout(WallpaperModel selected) {
    return Column(
      children: [
        Expanded(flex: 2, child: _buildWallpaperGrid()),
        Expanded(flex: 3, child: _buildDetailsPanel(selected)),
      ],
    );
  }

  // 🧱 Wallpaper grid selector
  Widget _buildWallpaperGrid() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: GridView.builder(
        itemCount: wallpapers.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, mainAxisSpacing: 20, crossAxisSpacing: 20),
        itemBuilder: (context, index) {
          final wall = wallpapers[index];
          final isSelected = selectedIndex == index;
          return GestureDetector(
            onTap: () => setState(() => selectedIndex = index),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(wall.image, fit: BoxFit.cover),
                ),
                if (isSelected)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.amber, width: 3),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  // 🧩 Wallpaper details panel
  Widget _buildDetailsPanel(WallpaperModel selected) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          bottomLeft: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(-3, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Preview',
              style: GoogleFonts.poppins(
                  fontSize: 22, fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          Center(
            child: Container(
              width: 220,
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black12, width: 2),
                image: DecorationImage(
                    image: AssetImage(selected.image), fit: BoxFit.cover),
              ),
            ),
          ),
          const SizedBox(height: 25),
          Text(selected.category,
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600, fontSize: 20)),
          const SizedBox(height: 10),
          Wrap(spacing: 8, children: selected.tags.map(_buildTag).toList()),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Text(selected.description,
                  style: GoogleFonts.poppins(
                      fontSize: 14, color: Colors.grey[700], height: 1.5)),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => setState(() => selected.toggleFavourite()),
                  icon: Icon(selected.isFavourite
                      ? Icons.favorite
                      : Icons.favorite_border),
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
                        final path = await _prepareWallpaper(selected.image);
                        await _setWallpaperWindows(path);
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Wallpaper applied successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      if (!mounted) return;
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
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Set to Wallpaper',
                      style:
                          GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 🏷️ Tag chips
  Widget _buildTag(String text) {
    return Chip(
      label: Text(text,
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87)),
      backgroundColor: const Color(0xFFEDEDED),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
    );
  }
}
