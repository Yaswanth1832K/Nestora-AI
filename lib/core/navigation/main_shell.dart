import 'package:flutter/material.dart';
import 'package:house_rental/features/search/presentation/pages/search_page.dart';
import 'package:house_rental/features/map/presentation/pages/map_page.dart';
import 'package:house_rental/features/favorites/presentation/pages/favorites_page.dart';
import 'package:house_rental/features/chat/presentation/pages/inbox_page.dart';
import 'package:house_rental/features/profile/presentation/pages/profile_page.dart';

import 'package:go_router/go_router.dart';
import 'package:house_rental/core/router/app_router.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith(AppRouter.search)) return 0;
    if (location.startsWith(AppRouter.map)) return 1;
    if (location.startsWith(AppRouter.favorites)) return 2;
    if (location.startsWith(AppRouter.chat)) return 3;
    if (location.startsWith(AppRouter.profile)) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0: context.go(AppRouter.search); break;
      case 1: context.go(AppRouter.map); break;
      case 2: context.go(AppRouter.favorites); break;
      case 3: context.go(AppRouter.chat); break;
      case 4: context.go(AppRouter.profile); break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _calculateSelectedIndex(context),
        onTap: (i) => _onItemTapped(i, context),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "Map"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Saved"),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: "Inbox"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
