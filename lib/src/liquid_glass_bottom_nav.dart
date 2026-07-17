import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

@immutable
class LiquidGlassBottomNavItem {
  const LiquidGlassBottomNavItem({
    required this.label,
    required this.icon,
    this.selectedIcon,
    this.semanticLabel,
  });

  final String label;
  final Widget icon;
  final Widget? selectedIcon;
  final String? semanticLabel;
}

class LiquidGlassBottomNavBar extends StatefulWidget {
  const LiquidGlassBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onSelected,
    this.onDragSelected,
    this.activeColor,
    this.inactiveColor,
    this.backgroundColor,
    this.height = 64,
    this.horizontalMargin = 14,
    this.selectionInset = 6,
    this.blurSigma = 12,
    this.borderRadius = 32,
    this.iconSize = 24,
    this.labelFontSize = 10,
    this.iconLabelGap = 5,
    this.animationDuration = const Duration(milliseconds: 180),
    this.enableHaptics = true,
  }) : assert(items.length > 1),
       assert(currentIndex >= 0 && currentIndex < items.length),
       assert(height > 0),
       assert(selectionInset >= 0);

  final int currentIndex;
  final List<LiquidGlassBottomNavItem> items;
  final ValueChanged<int> onSelected;
  final ValueChanged<int>? onDragSelected;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? backgroundColor;
  final double height;
  final double horizontalMargin;
  final double selectionInset;
  final double blurSigma;
  final double borderRadius;
  final double iconSize;
  final double labelFontSize;
  final double iconLabelGap;
  final Duration animationDuration;
  final bool enableHaptics;

  @override
  State<LiquidGlassBottomNavBar> createState() =>
      _LiquidGlassBottomNavBarState();
}

class _LiquidGlassBottomNavBarState extends State<LiquidGlassBottomNavBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _curve;
  double _position = 0;
  double _start = 0;
  double _target = 0;
  int? _previewIndex;
  bool _pressed = false;
  ImageFilter? _blurFilter;
  double? _blurSigma;

  ImageFilter get _blur {
    if (_blurFilter == null || _blurSigma != widget.blurSigma) {
      _blurSigma = widget.blurSigma;
      _blurFilter = ImageFilter.blur(
        sigmaX: widget.blurSigma,
        sigmaY: widget.blurSigma,
      );
    }
    return _blurFilter!;
  }

  @override
  void initState() {
    super.initState();
    _position = widget.currentIndex.toDouble();
    _target = _position;
    _controller =
        AnimationController(vsync: this, duration: widget.animationDuration)
          ..addListener(() {
            setState(() {
              _position = _start + ((_target - _start) * _curve.value);
            });
          });
    _curve = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
  }

  @override
  void didUpdateWidget(covariant LiquidGlassBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animationDuration != widget.animationDuration) {
      _controller.duration = widget.animationDuration;
    }
    if (oldWidget.currentIndex != widget.currentIndex &&
        _previewIndex == null) {
      _animateTo(widget.currentIndex.toDouble());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _animateTo(double value) {
    _start = _position;
    _target = value.clamp(0, widget.items.length - 1).toDouble();
    if ((_target - _start).abs() < 0.001) return;
    _controller.forward(from: 0);
  }

  void _preview(double dx, double width) {
    if (width <= 0) return;
    final itemWidth = width / widget.items.length;
    final normalized = dx.clamp(0.0, width - 0.01);
    final position = ((normalized / itemWidth) - 0.5).clamp(
      0.0,
      (widget.items.length - 1).toDouble(),
    );
    final index = (normalized / itemWidth).floor().clamp(
      0,
      widget.items.length - 1,
    );
    if (_position == position && _previewIndex == index) return;
    _controller.stop();
    setState(() {
      _position = position;
      _previewIndex = index;
    });
  }

  void _commitPreview() {
    final index = _previewIndex;
    if (index == null) return;
    setState(() {
      _previewIndex = null;
      _pressed = false;
    });
    _animateTo(index.toDouble());
    _select(index, fromDrag: true);
  }

  void _cancelPreview() {
    setState(() {
      _previewIndex = null;
      _pressed = false;
    });
    _animateTo(widget.currentIndex.toDouble());
  }

  void _select(int index, {bool fromDrag = false}) {
    if (widget.enableHaptics) HapticFeedback.lightImpact();
    if (index == widget.currentIndex) return;
    if (fromDrag && widget.onDragSelected != null) {
      widget.onDragSelected!(index);
    } else {
      widget.onSelected(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final active = widget.activeColor ?? theme.colorScheme.primary;
    final inactive =
        widget.inactiveColor ?? (dark ? Colors.white60 : Colors.black54);
    final base =
        widget.backgroundColor ??
        (dark ? const Color(0xFF1C1C1E) : Colors.white);
    final displayedIndex = _previewIndex ?? widget.currentIndex;
    final radius = BorderRadius.circular(widget.borderRadius);

    return SizedBox(
      height: widget.height,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: widget.horizontalMargin),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final itemWidth = width / widget.items.length;
            final pillWidth = itemWidth - (widget.selectionInset * 2);
            return GestureDetector(
              behavior: HitTestBehavior.translucent,
              dragStartBehavior: DragStartBehavior.down,
              onHorizontalDragUpdate: (event) =>
                  _preview(event.localPosition.dx, width),
              onHorizontalDragEnd: (_) => _commitPreview(),
              onHorizontalDragCancel: _cancelPreview,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: radius,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: dark ? 0.22 : 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: radius,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: BackdropFilter(
                          filter: _blur,
                          child: ColoredBox(
                            color: base.withValues(alpha: dark ? 0.58 : 0.48),
                          ),
                        ),
                      ),
                      AnimatedPositioned(
                        duration: _previewIndex == null
                            ? widget.animationDuration
                            : Duration.zero,
                        curve: Curves.easeOutCubic,
                        left: (itemWidth * _position) + widget.selectionInset,
                        top: widget.selectionInset,
                        width: pillWidth,
                        bottom: widget.selectionInset,
                        child: AnimatedScale(
                          scale: _pressed ? 1.04 : 1,
                          duration: const Duration(milliseconds: 120),
                          filterQuality: FilterQuality.low,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              color: Color.alphaBlend(
                                active.withValues(alpha: dark ? 0.24 : 0.13),
                                base.withValues(alpha: dark ? 0.76 : 0.72),
                              ),
                              border: Border.all(
                                color: active.withValues(alpha: 0.28),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          for (
                            var index = 0;
                            index < widget.items.length;
                            index++
                          )
                            Expanded(
                              child: _NavButton(
                                item: widget.items[index],
                                selected: displayedIndex == index,
                                activeColor: active,
                                inactiveColor: inactive,
                                iconSize: widget.iconSize,
                                labelFontSize: widget.labelFontSize,
                                iconLabelGap: widget.iconLabelGap,
                                onPressedChanged: (value) =>
                                    setState(() => _pressed = value),
                                onTap: () {
                                  _animateTo(index.toDouble());
                                  _select(index);
                                },
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.selected,
    required this.activeColor,
    required this.inactiveColor,
    required this.iconSize,
    required this.labelFontSize,
    required this.iconLabelGap,
    required this.onPressedChanged,
    required this.onTap,
  });

  final LiquidGlassBottomNavItem item;
  final bool selected;
  final Color activeColor;
  final Color inactiveColor;
  final double iconSize;
  final double labelFontSize;
  final double iconLabelGap;
  final ValueChanged<bool> onPressedChanged;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? activeColor : inactiveColor;
    return Semantics(
      button: true,
      selected: selected,
      label: item.semanticLabel ?? item.label,
      child: InkResponse(
        onTap: onTap,
        onHighlightChanged: onPressedChanged,
        containedInkWell: true,
        highlightShape: BoxShape.rectangle,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconTheme.merge(
              data: IconThemeData(color: color, size: iconSize),
              child: selected ? (item.selectedIcon ?? item.icon) : item.icon,
            ),
            SizedBox(height: iconLabelGap),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: labelFontSize,
                height: 1,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
