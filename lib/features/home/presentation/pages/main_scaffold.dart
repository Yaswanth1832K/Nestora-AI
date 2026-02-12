import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:house_rental/core/router/app_router.dart';

class MainScaffold extends ConsumerWidget {
  final Widget child;

  const MainScaffold({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.toString();
    
    int getSelectedIndex() {
      if (location.startsWith(AppRouter.search)) return 0;
      if (location.startsWith(AppRouter.favorites)) return 1;
      if (location.startsWith(AppRouter.map)) return 2;
      return 0;
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: getSelectedIndex(),
        onTap: (index) {
          switch (index) {
            case 0:
              context.go(AppRouter.search);
              break;
            case 1:
              context.go(AppRouter.favorites);
              break;
            case 2:
              context.go(AppRouter.map);
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
        ],
      ),
    );
  }
}
