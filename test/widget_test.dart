// Basic smoke test for the House Rental app.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:house_rental/app.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: HouseRentalApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('House Rental'), findsOneWidget);
  });
}
