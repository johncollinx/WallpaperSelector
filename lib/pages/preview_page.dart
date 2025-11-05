import 'dart:io';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_fonts/google_fonts.dart';
import 'package:win32/win32.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:ffi/ffi.dart';

import '../models/wallpaper_model.dart';

/// Win32 constants
const int SPI_SETDESKWALLPAPER = 20;
const int SPIF_UPDATEINIFILE = 0x01;
const int SPIF_SENDCHANGE = 0x02;

/// Wallpaper style enum (maps to Windows registry values)
enum WallpaperStyle { fill, fit, stretch, tile, center }

class WallpaperPreviewPage extends StatefulWidget {
  final WallpaperModel wallpaper;

  const WallpaperPreviewPage({super.key, required this.wallpaper});

  @override
  State<WallpaperPreviewPage> createState() => _WallpaperPreviewPageState();
}

class _WallpaperPreviewPageState extends State<WallpaperPreviewPage> {
  late List<WallpaperModel> wallpapers;
  late int selectedIndex;

  bool settingsOpen = false;
  WallpaperStyle selectedStyle = WallpaperStyle.fill;
  bool applyToAllScreens = true; // reserved for future use

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

  // --------------------- Helpers ---------------------

  /// Resize & convert asset to BMP at screen resolution, return absolute path.
  Future<String> _prepareBmpForWin(String assetPath) async {
    // load asset bytes
    final byteData = await rootBundle.load(assetPath);
    final bytes = byteData.buffer.asUint8List();

    // decode image
    final original = img.decodeImage(bytes);
    if (original == null) throw Exception('Failed to decode image');

    // get primary screen resolution via Win32
    final screenW = GetSystemMetrics(SM_CXSCREEN);
    final screenH = GetSystemMetrics(SM_CYSCREEN);

    // resize while preserving aspect ratio to at least cover screen
    // we choose cover-like behaviour (similar to "fill") so result has no empty bars
    final resized = _resizeCover(original, screenW, screenH);

    // encode to BMP (Windows handles BMP losslessly)
    final bmpBytes = img.encodeBmp(resized);

    // write to temp dir
    final dir = await getTemporaryDirectory();
    final outPath = '${dir.path}/wallpaper_tmp.bmp';
    final outFile = File(outPath);
    await outFile.writeAsBytes(bmpBytes, flush: true);

    return outFile.path;
  }

  /// Resize image to cover target while preserving aspect ratio.
  img.Image _resizeCover(img.Image src, int targetW, int targetH) {
    final srcW = src.width;
    final srcH = src.height;

    // compute scale to cover
    final scale = max(targetW / srcW, targetH / srcH);
    final newW = (srcW * scale).round();
    final newH = (srcH * scale).round();

    final resized = img.copyResize(
      src,
      width: newW,
      height: newH,
      interpolation: img.Interpolation.linear,
    );

    // center-crop to exact target size
    final offsetX = (newW - targetW) ~/ 2;
    final offsetY = (newH - targetH) ~/ 2;
    final cropped = img.copyCrop(resized, offsetX, offsetY, targetW, targetH);
    return cropped;
  }

  /// Set wallpaper Windows registry keys so system uses chosen style.
  /// This writes values to HKEY_CURRENT_USER\Control Panel\Desktop
  void _setWindowsWallpaperStyle(WallpaperStyle style) {
    final hkcu = HKEY_CURRENT_USER;
    final keyPath = TEXT('Control Panel\\Desktop');
    final phkResult = calloc<IntPtr>();

    final openRes = RegOpenKeyEx(hkcu, keyPath, 0, KEY_SET_VALUE, phkResult);
    calloc.free(keyPath);

    if (openRes != ERROR_SUCCESS) {
      calloc.free(phkResult);
      throw Exception('Failed to open registry key (error $openRes)');
    }

    final hKey = phkResult.value;

    // decide values
    String wallpaperStyleValue = '10'; // fill
    String tileWallpaperValue = '0';
    switch (style) {
      case WallpaperStyle.fill:
        wallpaperStyleValue = '10';
        tileWallpaperValue = '0';
        break;
      case WallpaperStyle.fit:
        wallpaperStyleValue = '6';
        tileWallpaperValue = '0';
        break;
      case WallpaperStyle.stretch:
        wallpaperStyleValue = '2';
        tileWallpaperValue = '0';
        break;
      case WallpaperStyle.tile:
        wallpaperStyleValue = '0';
        tileWallpaperValue = '1';
        break;
      case WallpaperStyle.center:
        wallpaperStyleValue = '0';
        tileWallpaperValue = '0';
        break;
    }

    final name1 = TEXT('WallpaperStyle');
    final val1 = TEXT(wallpaperStyleValue);
    RegSetValueEx(hKey, name1, 0, REG_SZ, val1, (wallpaperStyleValue.length + 1) * sizeOf<Int16>());
    calloc.free(name1);
    calloc.free(val1);

    final name2 = TEXT('TileWallpaper');
    final val2 = TEXT(tileWallpaperValue);
    RegSetValueEx(hKey, name2, 0, REG_SZ, val2, (tileWallpaperValue.length + 1) * sizeOf<Int16>());
    calloc.free(name2);
    calloc.free(val2);

    RegCloseKey(hKey);
    calloc.free(phkResult);
  }

  /// Apply wallpaper via SystemParametersInfoW after registry style updated.
  Future<void> _applyWallpaperWindows(String bmpPath, WallpaperStyle style) async {
    // First set registry style
    _setWindowsWallpaperStyle(style);

    // Now call SystemParametersInfoW
    final pathPtr = TEXT(bmpPath);
    final ok = SystemParametersInfoW(
      SPI_SETDESKWALLPAPER,
      0,
      pathPtr,
      SPIF_UPDATEINIFILE | SPIF_SENDCHANGE,
    );
    calloc.free(pathPtr);

    if (ok == 0) {
      throw Exception('SystemParametersInfoW failed (error ${GetLastError()})');
    }
  }

  // --------------------- UI & Actions ---------------------

  Future<void> _onApplyPressed() async {
    try {
      if (!Platform.isWindows) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This feature only works on Windows.'), backgroundColor: Colors.orange),
        );
        return;
      }

      final selected = wallpapers[selectedIndex];
      final bmpPath = await _prepareBmpForWin(selected.image);
      await _applyWallpaperWindows(bmpPath, selectedStyle);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Wallpaper applied successfully!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to apply wallpaper: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // --------------------- Build ---------------------

  @override
  Widget build(BuildContext context) {
    final selected = wallpapers[selectedIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Wallpaper Preview', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.black)),
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.black87), onPressed: () => Navigator.pop(context)),
        actions: [
          IconButton(
            icon: Icon(settingsOpen ? Icons.settings : Icons.settings_outlined),
            onPressed: () => setState(() => settingsOpen = !settingsOpen),
            tooltip: 'Wallpaper Settings',
          ),
        ],
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 900;
        return Row(
          children: [
            // Left: gallery / preview (takes most space)
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: GridView.builder(
                  itemCount: wallpapers.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isNarrow ? 2 : 3,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    childAspectRatio: 0.7,
                  ),
                  itemBuilder: (context, index) {
                    final wall = wallpapers[index];
                    final isSelected = selectedIndex == index;
                    return GestureDetector(
                      onTap: () => setState(() => selectedIndex = index),
                      child: Stack(children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(wall.image, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                        ),
                        Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: Colors.black26)),
                        Positioned(bottom: 12, left: 12, child: Text(wall.name, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14))),
                        Positioned(top: 10, right: 10, child: Icon(wall.isFavourite ? Icons.favorite : Icons.favorite_border, color: wall.isFavourite ? Colors.amber : Colors.white)),
                        if (isSelected)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.amber, width: 3)),
                            ),
                          ),
                      ]),
                    );
                  },
                ),
              ),
            ),

            // Right: details + collapsible settings panel
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.all(30),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(-3, 3))],
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Preview', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 20),
                  Center(
                    child: Container(
                      width: isNarrow ? 320 : 220,
                      height: isNarrow ? 220 : 180,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.black12, width: 2),
                        image: DecorationImage(image: AssetImage(selected.image), fit: BoxFit.cover),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Text(selected.name, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 20)),
                  const SizedBox(height: 10),
                  Text(selected.category, style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600])),
                  const SizedBox(height: 20),
                  Wrap(spacing: 8, children: selected.tags.map((t) => _buildTag(t)).toList()),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(selected.description, style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700], height: 1.5)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Row with favorite + apply
                  Row(children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => setState(() => selected.toggleFavourite()),
                        icon: Icon(selected.isFavourite ? Icons.favorite : Icons.favorite_border),
                        label: Text(selected.isFavourite ? 'Remove Favourite' : 'Save to Favourites'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _onApplyPressed,
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFB23F), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        child: Text('Set to Wallpaper', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ]),

                  // Collapsible settings panel (matches PNG)
                  AnimatedCrossFade(
                    firstChild: const SizedBox.shrink(),
                    secondChild: _buildSettingsPanel(),
                    crossFadeState: settingsOpen ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 220),
                  ),
                ]),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSettingsPanel() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey[200]!), borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Wallpaper Settings', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Text('Choose how the wallpaper is displayed on your desktop.', style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600])),
        const SizedBox(height: 12),

        // radio buttons for fit modes
        for (final style in WallpaperStyle.values) ...[
          RadioListTile<WallpaperStyle>(
            value: style,
            groupValue: selectedStyle,
            title: Text(style.name.toUpperCase(), style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            subtitle: Text(_styleSubtitle(style), style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
            onChanged: (v) => setState(() => selectedStyle = v!),
            dense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ],
        const SizedBox(height: 8),

        // extra options
        Row(children: [
          const Icon(Icons.info_outline, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text('Applying will update Windows wallpaper settings so the change is system-wide.', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700]))),
        ]),
      ]),
    );
  }

  String _styleSubtitle(WallpaperStyle s) {
    switch (s) {
      case WallpaperStyle.fill:
        return 'Fill — crop to fill screen (recommended)';
      case WallpaperStyle.fit:
        return 'Fit — fit inside screen without cropping';
      case WallpaperStyle.stretch:
        return 'Stretch — stretch to fill (may distort)';
      case WallpaperStyle.tile:
        return 'Tile — repeat image to fill';
      case WallpaperStyle.center:
        return 'Center — center image';
    }
  }

  Widget _buildTag(String text) {
    return Chip(label: Text(text, style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87)), backgroundColor: const Color(0xFFEDEDED), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)));
  }
}
