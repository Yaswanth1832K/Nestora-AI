import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:house_rental/features/auth/presentation/providers/auth_providers.dart';
import 'package:house_rental/core/router/app_router.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.blue.shade100,
                    child: const Icon(Icons.person, size: 50, color: Colors.blue),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.displayName ?? "Guest User",
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    user?.email ?? "Log in to access all features",
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.calendar_today, color: Colors.blue),
              title: const Text("Visit Requests (Owner)"),
              subtitle: const Text("Manage requests for your properties"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(AppRouter.ownerRequests),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.home_outlined, color: Colors.blue),
              title: const Text("My Listings"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Future implementation
              },
            ),
            const Divider(),
            const SizedBox(height: 24),
            if (user != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => ref.read(authRepositoryProvider).signOut(),
                    child: const Text("Sign Out"),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
