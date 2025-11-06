import 'dart:math';
import 'package:flutter/material.dart';
import '../models/wallpaper_model.dart';
import '../pages/home_page.dart';
import '../pages/browse_category_page.dart';
import '../pages/favourites_page.dart';
import '../pages/settings_page.dart';
import '../pages/preview_page.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;
    late Widget page;

    switch (settings.name) {
      case '/':
        page = const HomePage();
        break;
      case '/browse':
        page = const BrowseCategoryPage();
        break;
      case '/favourites':
        page = const FavouritesPage();
        break;
      case '/settings':
        page = const SettingsPage();
        break;
      case '/preview':
        if (args is WallpaperModel) {
          page = WallpaperPreviewPage(wallpaper: args);
        } else {
          page = const Scaffold(
            body: Center(
              child: Text('Invalid arguments for Preview Page'),
            ),
          );
        }
        break;
      default:
        page = const Scaffold(
          body: Center(child: Text('404 - Page Not Found')),
        );
    }

    return _randomTransition(page, settings);
  }

  // 🎞️ Random transition for visual variety
  static Route _randomTransition(Widget page, RouteSettings settings) {
    final random = Random().nextInt(3);
    switch (random) {
      case 0:
        return _fadeRoute(page, settings);
      case 1:
        return _slideRoute(page, settings);
      default:
        return _scaleRoute(page, settings);
    }
  }

  // 🌫 Fade transition
  static PageRouteBuilder _fadeRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) =>
          FadeTransition(opacity: animation, child: child),
    );
  }

  // ⬅️ Slide transition
  static PageRouteBuilder _slideRoute(Widget page, RouteSettings settings) {
    final beginOffsets = [
      const Offset(1, 0), // from right
      const Offset(-1, 0), // from left
      const Offset(0, 1), // from bottom
      const Offset(0, -1), // from top
    ];
    final begin = beginOffsets[Random().nextInt(4)];

    return PageRouteBuilder(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 450),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        final offsetAnimation = Tween(begin: begin, end: Offset.zero).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeInOut),
        );
        return SlideTransition(position: offsetAnimation, child: child);
      },
    );
  }

  // 🔍 Scale (zoom) transition
  static PageRouteBuilder _scaleRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        final curved =
            CurvedAnimation(parent: animation, curve: Curves.easeInOut);
        return ScaleTransition(scale: curved, child: child);
      },
    );
  }
}
