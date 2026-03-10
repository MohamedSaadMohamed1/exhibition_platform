import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Image optimization utilities
class ImageOptimizer {
  /// Get optimized image URL with size parameters
  /// Works with Firebase Storage and other CDNs that support URL parameters
  static String getOptimizedUrl(
    String originalUrl, {
    int? width,
    int? height,
    int quality = 80,
  }) {
    if (originalUrl.isEmpty) return originalUrl;

    // For Firebase Storage URLs with image resize extension
    if (originalUrl.contains('firebasestorage.googleapis.com')) {
      final params = <String>[];
      if (width != null) params.add('w=$width');
      if (height != null) params.add('h=$height');
      params.add('q=$quality');

      final separator = originalUrl.contains('?') ? '&' : '?';
      return '$originalUrl${separator}${params.join('&')}';
    }

    return originalUrl;
  }

  /// Get thumbnail URL
  static String getThumbnailUrl(String originalUrl, {int size = 150}) {
    return getOptimizedUrl(originalUrl, width: size, height: size, quality: 70);
  }

  /// Get preview URL for list items
  static String getPreviewUrl(String originalUrl) {
    return getOptimizedUrl(originalUrl, width: 400, quality: 75);
  }

  /// Get full size URL
  static String getFullSizeUrl(String originalUrl) {
    return getOptimizedUrl(originalUrl, width: 1200, quality: 85);
  }
}

/// Optimized network image widget
class OptimizedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;
  final int memCacheWidth;
  final int memCacheHeight;

  const OptimizedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
    this.memCacheWidth = 400,
    this.memCacheHeight = 400,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return _buildPlaceholder();
    }

    final optimizedUrl = ImageOptimizer.getOptimizedUrl(
      imageUrl,
      width: width?.toInt() ?? memCacheWidth,
    );

    Widget image = CachedNetworkImage(
      imageUrl: optimizedUrl,
      width: width,
      height: height,
      fit: fit,
      memCacheWidth: memCacheWidth,
      memCacheHeight: memCacheHeight,
      placeholder: (context, url) => placeholder ?? _buildPlaceholder(),
      errorWidget: (context, url, error) => errorWidget ?? _buildErrorWidget(),
      fadeInDuration: const Duration(milliseconds: 200),
      fadeOutDuration: const Duration(milliseconds: 200),
    );

    if (borderRadius != null) {
      image = ClipRRect(
        borderRadius: borderRadius!,
        child: image,
      );
    }

    return image;
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[800],
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[800],
      child: const Center(
        child: Icon(Icons.broken_image, color: Colors.grey),
      ),
    );
  }
}

/// Avatar image with optimization
class OptimizedAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final String? fallbackText;
  final Color? backgroundColor;

  const OptimizedAvatar({
    super.key,
    this.imageUrl,
    this.radius = 24,
    this.fallbackText,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      final size = (radius * 2).toInt();
      return CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor ?? Colors.grey[800],
        backgroundImage: CachedNetworkImageProvider(
          ImageOptimizer.getThumbnailUrl(imageUrl!, size: size),
          maxWidth: size,
          maxHeight: size,
        ),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
      child: Text(
        _getInitials(),
        style: TextStyle(
          fontSize: radius * 0.7,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
    );
  }

  String _getInitials() {
    if (fallbackText == null || fallbackText!.isEmpty) return '?';

    final words = fallbackText!.trim().split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return fallbackText![0].toUpperCase();
  }
}

/// Image carousel with lazy loading
class LazyImageCarousel extends StatefulWidget {
  final List<String> imageUrls;
  final double height;
  final BorderRadius? borderRadius;
  final void Function(int)? onPageChanged;

  const LazyImageCarousel({
    super.key,
    required this.imageUrls,
    this.height = 200,
    this.borderRadius,
    this.onPageChanged,
  });

  @override
  State<LazyImageCarousel> createState() => _LazyImageCarouselState();
}

class _LazyImageCarouselState extends State<LazyImageCarousel> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      return Container(
        height: widget.height,
        color: Colors.grey[800],
        child: const Center(
          child: Icon(Icons.image, size: 48, color: Colors.grey),
        ),
      );
    }

    return Stack(
      children: [
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.imageUrls.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
              widget.onPageChanged?.call(index);
            },
            itemBuilder: (context, index) {
              // Only load current and adjacent images
              final shouldLoad = (index - _currentPage).abs() <= 1;

              if (!shouldLoad) {
                return Container(color: Colors.grey[800]);
              }

              return OptimizedImage(
                imageUrl: widget.imageUrls[index],
                height: widget.height,
                width: double.infinity,
                fit: BoxFit.cover,
                borderRadius: widget.borderRadius,
              );
            },
          ),
        ),
        if (widget.imageUrls.length > 1)
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.imageUrls.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: index == _currentPage ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: index == _currentPage
                        ? Theme.of(context).primaryColor
                        : Colors.white54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
