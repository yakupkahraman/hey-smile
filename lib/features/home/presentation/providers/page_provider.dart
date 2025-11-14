import 'package:flutter/material.dart';

class PageProvider with ChangeNotifier {
  String _currentRoute = '/home';

  String get currentRoute => _currentRoute;

  void updateRoute(String route) {
    _currentRoute = route;
    notifyListeners();
  }
}

class NavigationItemData {
  final String route;
  final IconData unSelectedIcon;
  final IconData selectedIcon;

  NavigationItemData({
    required this.route,
    required this.unSelectedIcon,
    required this.selectedIcon,
  });
}