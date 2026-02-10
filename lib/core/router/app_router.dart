import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:house_rental/features/listings/domain/entities/listing_entity.dart';
import 'package:house_rental/features/listings/presentation/pages/listing_details_page.dart';
import 'package:house_rental/features/search/presentation/pages/search_page.dart';
import 'package:house_rental/features/listings/presentation/pages/post_property_page.dart';
import 'package:house_rental/features/favorites/presentation/pages/favorites_page.dart';
import 'package:house_rental/features/chat/presentation/pages/chat_page.dart';
import 'package:house_rental/features/chat/presentation/pages/inbox_page.dart';
import 'package:house_rental/features/profile/presentation/pages/profile_page.dart';
import 'package:house_rental/features/map/presentation/pages/map_page.dart';
import 'package:house_rental/core/router/splash_screen.dart';
import 'package:house_rental/features/visit_requests/presentation/pages/owner_requests_page.dart';
import 'package:house_rental/core/navigation/main_shell.dart';
import 'package:house_rental/main.dart';

/// Application routing configuration using Riverpod.
/// We use the global rootNavigatorKey to prevent "!keyReservation.contains(key)" assertion errors.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRouter.search,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: AppRouter.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRouter.search,
            builder: (context, state) => const SearchPage(),
          ),
          GoRoute(
            path: AppRouter.map,
            builder: (context, state) => const MapPage(),
          ),
          GoRoute(
            path: AppRouter.favorites,
            builder: (context, state) => const FavoritesPage(),
          ),
          GoRoute(
            path: AppRouter.chat,
            builder: (context, state) => const InboxPage(),
          ),
          GoRoute(
            path: AppRouter.profile,
            builder: (context, state) => const ProfilePage(),
          ),
        ],
      ),
      GoRoute(
        path: AppRouter.postProperty,
        builder: (context, state) => const PostPropertyPage(),
      ),
      GoRoute(
        path: AppRouter.listingDetails,
        builder: (context, state) {
          final listing = state.extra as ListingEntity;
          return ListingDetailsPage(listing: listing);
        },
      ),
      GoRoute(
        path: '/chat-detail',
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>;
          final chatRoomId = extras['chatRoomId'] as String;
          final title = extras['title'] as String;
          return ChatPage(chatRoomId: chatRoomId, title: title);
        },
      ),
      GoRoute(
        path: AppRouter.ownerRequests,
        builder: (context, state) => const OwnerRequestsPage(),
      ),
    ],
  );
});

final class AppRouter {
  AppRouter._();

  static const String splash = '/';
  static const String search = '/search';
  static const String postProperty = '/post-property';
  static const String listingDetails = '/listing';
  static const String favorites = '/favorites';
  static const String chat = '/chat';
  static const String map = '/map';
  static const String profile = '/profile';
  static const String ownerRequests = '/owner-requests';
}
