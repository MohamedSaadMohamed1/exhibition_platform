import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Lazy loading wrapper for expensive widgets
class LazyLoader extends StatefulWidget {
  final Widget Function(BuildContext context) builder;
  final Widget? placeholder;
  final double visibilityThreshold;
  final Duration delay;

  const LazyLoader({
    super.key,
    required this.builder,
    this.placeholder,
    this.visibilityThreshold = 0.1,
    this.delay = Duration.zero,
  });

  @override
  State<LazyLoader> createState() => _LazyLoaderState();
}

class _LazyLoaderState extends State<LazyLoader> {
  bool _isLoaded = false;
  bool _isVisible = false;

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      onVisibilityChanged: _onVisibilityChanged,
      child: _isLoaded
          ? widget.builder(context)
          : widget.placeholder ?? const SizedBox.shrink(),
    );
  }

  void _onVisibilityChanged(bool visible) {
    if (visible && !_isVisible) {
      _isVisible = true;
      if (widget.delay == Duration.zero) {
        _load();
      } else {
        Future.delayed(widget.delay, _load);
      }
    }
  }

  void _load() {
    if (mounted && !_isLoaded) {
      setState(() => _isLoaded = true);
    }
  }
}

/// Simple visibility detector using LayoutBuilder and scroll notifications
class VisibilityDetector extends StatefulWidget {
  final Widget child;
  final void Function(bool visible) onVisibilityChanged;

  const VisibilityDetector({
    super.key,
    required this.child,
    required this.onVisibilityChanged,
  });

  @override
  State<VisibilityDetector> createState() => _VisibilityDetectorState();
}

class _VisibilityDetectorState extends State<VisibilityDetector> {
  final GlobalKey _key = GlobalKey();
  bool _wasVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkVisibility());
  }

  void _checkVisibility() {
    if (!mounted) return;

    final RenderObject? renderObject = _key.currentContext?.findRenderObject();
    if (renderObject == null) return;

    final RenderAbstractViewport? viewport = RenderAbstractViewport.of(renderObject);
    if (viewport == null) {
      // Not in a scrollable, assume visible
      if (!_wasVisible) {
        _wasVisible = true;
        widget.onVisibilityChanged(true);
      }
      return;
    }

    final RevealedOffset? revealed = viewport.getOffsetToReveal(renderObject, 0.0);
    if (revealed == null) return;

    final bool isVisible = revealed.offset >= 0;

    if (isVisible != _wasVisible) {
      _wasVisible = isVisible;
      widget.onVisibilityChanged(isVisible);
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        _checkVisibility();
        return false;
      },
      child: KeyedSubtree(
        key: _key,
        child: widget.child,
      ),
    );
  }
}

/// Lazy list that only builds visible items
class LazyListView<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Widget? separator;
  final EdgeInsetsGeometry? padding;
  final ScrollController? controller;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final Widget? placeholder;

  const LazyListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.separator,
    this.padding,
    this.controller,
    this.physics,
    this.shrinkWrap = false,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller,
      physics: physics,
      shrinkWrap: shrinkWrap,
      padding: padding,
      itemCount: separator != null ? items.length * 2 - 1 : items.length,
      itemBuilder: (context, index) {
        if (separator != null) {
          if (index.isOdd) {
            return separator!;
          }
          index = index ~/ 2;
        }

        return LazyLoader(
          placeholder: placeholder ?? const SizedBox(height: 100),
          builder: (context) => itemBuilder(context, items[index], index),
        );
      },
    );
  }
}

/// Staggered lazy grid for masonry layouts
class LazyGridView<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final EdgeInsetsGeometry? padding;
  final ScrollController? controller;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final Widget? placeholder;

  const LazyGridView({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.crossAxisCount = 2,
    this.mainAxisSpacing = 8,
    this.crossAxisSpacing = 8,
    this.padding,
    this.controller,
    this.physics,
    this.shrinkWrap = false,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: controller,
      physics: physics,
      shrinkWrap: shrinkWrap,
      padding: padding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return LazyLoader(
          placeholder: placeholder ??
              Container(
                color: Colors.grey[800],
              ),
          builder: (context) => itemBuilder(context, items[index], index),
        );
      },
    );
  }
}

/// Deferred widget that loads after initial frame
class DeferredWidget extends StatefulWidget {
  final Widget Function(BuildContext context) builder;
  final Widget? placeholder;
  final Duration delay;

  const DeferredWidget({
    super.key,
    required this.builder,
    this.placeholder,
    this.delay = const Duration(milliseconds: 100),
  });

  @override
  State<DeferredWidget> createState() => _DeferredWidgetState();
}

class _DeferredWidgetState extends State<DeferredWidget> {
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) {
        setState(() => _isLoaded = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded) {
      return widget.placeholder ?? const SizedBox.shrink();
    }
    return widget.builder(context);
  }
}
