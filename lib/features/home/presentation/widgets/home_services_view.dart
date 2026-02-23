import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:house_rental/core/router/app_router.dart';

class HomeServicesView extends StatelessWidget {
  const HomeServicesView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> services = [
      {'name': 'Painting', 'icon': Icons.format_paint, 'badge': '25% Off', 'color': Colors.blue},
      {'name': 'Cleaning', 'icon': Icons.cleaning_services, 'badge': '60% Off', 'color': Colors.teal},
      {'name': 'Plumbing', 'icon': Icons.plumbing, 'badge': 'Starts ₹299', 'color': Colors.cyan},
      {'name': 'Electrical', 'icon': Icons.electrical_services, 'badge': 'Safe', 'color': Colors.indigo},
      {'name': 'AC Repair', 'icon': Icons.ac_unit, 'badge': 'Hot Deal', 'color': Colors.lightBlue},
      {'name': 'Packers', 'icon': Icons.local_shipping, 'badge': 'Secure', 'color': Colors.purple},
      {'name': 'Pest Ctrl', 'icon': Icons.bug_report, 'badge': 'Certified', 'color': Colors.orange},
      {'name': 'Carpentry', 'icon': Icons.handyman, 'badge': 'Expert', 'color': Colors.brown},
    ];

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              return _ServiceCard(service: service, isDark: isDark);
            },
          ),
        ),
      ],
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final Map<String, dynamic> service;
  final bool isDark;

  const _ServiceCard({required this.service, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final color = service['color'] as Color;
    return GestureDetector(
      onTap: () => context.push(
        AppRouter.serviceBooking,
        extra: {
          'serviceName': service['name'],
          'serviceIcon': service['icon'],
        },
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
          boxShadow: [
            if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Positioned(
                right: -15,
                bottom: -15,
                child: Icon(
                  service['icon'] as IconData,
                  size: 80,
                  color: color.withOpacity(isDark ? 0.1 : 0.05),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        service['badge'] as String,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Icon(service['icon'] as IconData, size: 20, color: color),
                        const SizedBox(width: 8),
                        Text(
                          service['name'] as String,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

