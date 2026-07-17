# liquid_glass_bottom_nav

A lightweight, draggable liquid-glass bottom navigation bar for Flutter. It is
implemented entirely in Dart and works on Android, iOS, web, macOS, Windows,
and Linux.

## Features

- Backdrop blur with configurable glass color
- Animated selection pill
- Tap and horizontal drag selection
- Optional haptic feedback
- Light and dark theme support
- Configurable dimensions, spacing, colors, and motion
- Accessible button and selected-state semantics
- No platform channels or native code

## Installation

Until the package is published to pub.dev:

```yaml
dependencies:
  liquid_glass_bottom_nav:
    git:
      url: https://github.com/doubleuj22/liquid_glass_bottom_nav.git
      ref: main
```

For a local checkout:

```yaml
dependencies:
  liquid_glass_bottom_nav:
    path: ../liquid_glass_bottom_nav
```

## Usage

```dart
import 'package:flutter/material.dart';
import 'package:liquid_glass_bottom_nav/liquid_glass_bottom_nav.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Center(child: Text('Page $index')),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: LiquidGlassBottomNavBar(
          currentIndex: index,
          onSelected: (value) => setState(() => index = value),
          onDragSelected: (value) => setState(() => index = value),
          items: const [
            LiquidGlassBottomNavItem(
              label: 'Home',
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
            ),
            LiquidGlassBottomNavItem(
              label: 'Search',
              icon: Icon(Icons.search),
            ),
            LiquidGlassBottomNavItem(
              label: 'Profile',
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
            ),
          ],
        ),
      ),
    );
  }
}
```

`Scaffold.extendBody` should be enabled when content needs to remain visible
through the glass.

## Customization

The constructor exposes active and inactive colors, background color, height,
horizontal margin, selection inset, blur strength, radius, icon size, label
size, icon-label spacing, animation duration, and haptic feedback.

## Publishing checklist

1. Add screenshots or a GIF to `example/` or `doc/`.
2. Run `flutter test` and `flutter analyze`.
3. Run `dart pub publish --dry-run`.
4. Push the folder to its own GitHub repository.
5. Publish with `dart pub publish` when ready.

## License

MIT
