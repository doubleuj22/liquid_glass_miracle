import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_bottom/liquid_glass_bottom.dart';

void main() {
  testWidgets('renders items and reports a tapped selection', (tester) async {
    var selected = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: LiquidGlassBottomNavBar(
            currentIndex: selected,
            enableHaptics: false,
            onSelected: (value) => selected = value,
            items: const [
              LiquidGlassBottomNavItem(
                label: 'Home',
                icon: Icon(Icons.home_outlined),
              ),
              LiquidGlassBottomNavItem(
                label: 'Search',
                icon: Icon(Icons.search),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);
    await tester.tap(find.text('Search'));
    await tester.pumpAndSettle();
    expect(selected, 1);
  });

  testWidgets('exposes selected semantics', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: LiquidGlassBottomNavBar(
            currentIndex: 1,
            enableHaptics: false,
            onSelected: (_) {},
            items: const [
              LiquidGlassBottomNavItem(label: 'Home', icon: Icon(Icons.home)),
              LiquidGlassBottomNavItem(
                label: 'Settings',
                icon: Icon(Icons.settings),
              ),
            ],
          ),
        ),
      ),
    );

    final semantics = tester.getSemantics(find.text('Settings'));
    expect(semantics.flagsCollection.isSelected, Tristate.isTrue);
  });
}
