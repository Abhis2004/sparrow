import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Representation of an image item to display in [FullScreenImageViewer].
class ImageViewerItem {
  final ImageProvider? imageProvider;
  final String? imagePath; // Can be a local file path, asset path, or network URL
  final Uint8List? bytes;
  final String? title;
  final String? subtitle;
  final String? caption;
  final String? heroTag;
  final Map<String, dynamic>? extras;

  const ImageViewerItem({
    this.imageProvider,
    this.imagePath,
    this.bytes,
    this.title,
    this.subtitle,
    this.caption,
    this.heroTag,
    this.extras,
  });

  factory ImageViewerItem.fromPath(
    String path, {
    String? title,
    String? subtitle,
    String? caption,
    String? heroTag,
    Map<String, dynamic>? extras,
  }) {
    return ImageViewerItem(
      imagePath: path,
      title: title,
      subtitle: subtitle,
      caption: caption,
      heroTag: heroTag,
      extras: extras,
    );
  }

  factory ImageViewerItem.fromUrl(
    String url, {
    String? title,
    String? subtitle,
    String? caption,
    String? heroTag,
    Map<String, dynamic>? extras,
  }) {
    return ImageViewerItem(
      imagePath: url,
      title: title,
      subtitle: subtitle,
      caption: caption,
      heroTag: heroTag,
      extras: extras,
    );
  }

  factory ImageViewerItem.fromAsset(
    String assetName, {
    String? title,
    String? subtitle,
    String? caption,
    String? heroTag,
    Map<String, dynamic>? extras,
  }) {
    return ImageViewerItem(
      imagePath: assetName,
      title: title,
      subtitle: subtitle,
      caption: caption,
      heroTag: heroTag,
      extras: extras,
    );
  }

  factory ImageViewerItem.fromBytes(
    Uint8List bytes, {
    String? title,
    String? subtitle,
    String? caption,
    String? heroTag,
    Map<String, dynamic>? extras,
  }) {
    return ImageViewerItem(
      bytes: bytes,
      title: title,
      subtitle: subtitle,
      caption: caption,
      heroTag: heroTag,
      extras: extras,
    );
  }

  /// Resolves an appropriate [ImageProvider] for this item.
  ImageProvider resolveImageProvider() {
    if (imageProvider != null) return imageProvider!;
    if (bytes != null) return MemoryImage(bytes!);

    final path = imagePath ?? '';
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return NetworkImage(path);
    } else if (path.startsWith('assets/') || path.startsWith('asset:')) {
      final cleanPath = path.startsWith('asset:') ? path.substring(6) : path;
      return AssetImage(cleanPath);
    } else {
      return FileImage(File(path));
    }
  }

  bool get isNetwork =>
      imagePath != null &&
      (imagePath!.startsWith('http://') || imagePath!.startsWith('https://'));

  bool get isAsset =>
      imagePath != null &&
      (imagePath!.startsWith('assets/') || imagePath!.startsWith('asset:'));
}

/// A full-screen interactive image viewer widget with pinch-to-zoom,
/// double-tap zoom, swipe gallery, vertical drag-to-dismiss, image rotation,
/// glassmorphism controls, thumbnail strip, and Hero animation support.
class FullScreenImageViewer extends StatefulWidget {
  final List<ImageViewerItem> items;
  final int initialIndex;
  final bool showThumbnails;
  final bool allowRotation;
  final bool showCounter;
  final Color backgroundColor;
  final void Function(ImageViewerItem item)? onDownload;
  final void Function(ImageViewerItem item)? onShare;
  final void Function(int index)? onPageChanged;

  const FullScreenImageViewer({
    super.key,
    required this.items,
    this.initialIndex = 0,
    this.showThumbnails = true,
    this.allowRotation = true,
    this.showCounter = true,
    this.backgroundColor = const Color(0xFF090D16),
    this.onDownload,
    this.onShare,
    this.onPageChanged,
  }) : assert(items.length > 0, 'items list cannot be empty');

  /// Convenience static method to open the viewer in a dark full-screen modal route.
  static Future<T?> open<T>(
    BuildContext context, {
    required List<ImageViewerItem> items,
    int initialIndex = 0,
    bool showThumbnails = true,
    bool allowRotation = true,
    bool showCounter = true,
    Color backgroundColor = const Color(0xFF090D16),
    void Function(ImageViewerItem item)? onDownload,
    void Function(ImageViewerItem item)? onShare,
    void Function(int index)? onPageChanged,
  }) {
    return Navigator.of(context).push<T>(
      PageRouteBuilder<T>(
        opaque: false,
        barrierColor: Colors.black.withValues(alpha: 0.9),
        barrierDismissible: true,
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: FullScreenImageViewer(
              items: items,
              initialIndex: initialIndex,
              showThumbnails: showThumbnails,
              allowRotation: allowRotation,
              showCounter: showCounter,
              backgroundColor: backgroundColor,
              onDownload: onDownload,
              onShare: onShare,
              onPageChanged: onPageChanged,
            ),
          );
        },
      ),
    );
  }

  /// Convenience static method for opening a single image.
  static Future<T?> openSingle<T>(
    BuildContext context, {
    required String imagePath,
    String? title,
    String? subtitle,
    String? caption,
    String? heroTag,
    bool allowRotation = true,
    void Function(ImageViewerItem item)? onDownload,
    void Function(ImageViewerItem item)? onShare,
  }) {
    return open<T>(
      context,
      items: [
        ImageViewerItem(
          imagePath: imagePath,
          title: title,
          subtitle: subtitle,
          caption: caption,
          heroTag: heroTag,
        ),
      ],
      showThumbnails: false,
      allowRotation: allowRotation,
      onDownload: onDownload,
      onShare: onShare,
    );
  }

  /// Convenience static method for opening a list of image paths or URLs.
  static Future<T?> openGallery<T>(
    BuildContext context, {
    required List<String> imagePaths,
    int initialIndex = 0,
    List<String>? titles,
    List<String>? captions,
    bool showThumbnails = true,
    bool allowRotation = true,
    void Function(ImageViewerItem item)? onDownload,
    void Function(ImageViewerItem item)? onShare,
  }) {
    final items = List<ImageViewerItem>.generate(imagePaths.length, (index) {
      return ImageViewerItem(
        imagePath: imagePaths[index],
        title: titles != null && index < titles.length ? titles[index] : null,
        caption: captions != null && index < captions.length ? captions[index] : null,
        heroTag: 'gallery_image_$index',
      );
    });

    return open<T>(
      context,
      items: items,
      initialIndex: initialIndex,
      showThumbnails: showThumbnails,
      allowRotation: allowRotation,
      onDownload: onDownload,
      onShare: onShare,
    );
  }

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late int _currentIndex;
  bool _showOverlay = true;

  // Zoom controllers per page index
  final Map<int, TransformationController> _transformationControllers = {};
  late AnimationController _doubleTapAnimController;
  Animation<Matrix4>? _doubleTapAnimation;

  // Rotation state per page index (0 = 0 deg, 1 = 90 deg, 2 = 180 deg, 3 = 270 deg)
  final Map<int, int> _rotations = {};

  // Vertical drag-to-dismiss state
  double _dragOffsetY = 0.0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, widget.items.length - 1);
    _pageController = PageController(initialPage: _currentIndex);

    _doubleTapAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    )..addListener(() {
        if (_doubleTapAnimation != null) {
          _getTransformationController(_currentIndex).value =
              _doubleTapAnimation!.value;
        }
      });
  }

  TransformationController _getTransformationController(int index) {
    return _transformationControllers.putIfAbsent(
      index,
      () => TransformationController(),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _doubleTapAnimController.dispose();
    for (final controller in _transformationControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    // Reset zoom level on current image if needed
    _getTransformationController(index).value = Matrix4.identity();
    widget.onPageChanged?.call(index);
  }

  void _toggleOverlay() {
    setState(() {
      _showOverlay = !_showOverlay;
    });
  }

  void _rotateImage() {
    setState(() {
      final currentRotation = _rotations[_currentIndex] ?? 0;
      _rotations[_currentIndex] = (currentRotation + 1) % 4;
    });
  }

  void _resetZoom() {
    final controller = _getTransformationController(_currentIndex);
    if (controller.value != Matrix4.identity()) {
      _doubleTapAnimation = Matrix4Tween(
        begin: controller.value,
        end: Matrix4.identity(),
      ).animate(
        CurvedAnimation(
          parent: _doubleTapAnimController,
          curve: Curves.easeInOutCubic,
        ),
      );
      _doubleTapAnimController.forward(from: 0.0);
    }
  }

  void _handleDoubleTap(TapDownDetails details) {
    final controller = _getTransformationController(_currentIndex);
    final Matrix4 currentMatrix = controller.value;
    final double currentScale = currentMatrix.getMaxScaleOnAxis();

    final Matrix4 targetMatrix;
    if (currentScale > 1.2) {
      // Zoom out to normal
      targetMatrix = Matrix4.identity();
    } else {
      // Zoom in to 2.5x around tap position
      final position = details.localPosition;
      final double targetScale = 2.5;

      final double x = -position.dx * (targetScale - 1);
      final double y = -position.dy * (targetScale - 1);

      targetMatrix = Matrix4.identity()
        ..setEntry(0, 3, x)
        ..setEntry(1, 3, y)
        ..setEntry(0, 0, targetScale)
        ..setEntry(1, 1, targetScale);
    }

    _doubleTapAnimation = Matrix4Tween(
      begin: currentMatrix,
      end: targetMatrix,
    ).animate(
      CurvedAnimation(
        parent: _doubleTapAnimController,
        curve: Curves.easeOutCubic,
      ),
    );
    _doubleTapAnimController.forward(from: 0.0);
  }

  bool get _isCurrentZoomed {
    final controller = _transformationControllers[_currentIndex];
    if (controller == null) return false;
    return controller.value.getMaxScaleOnAxis() > 1.05;
  }

  @override
  Widget build(BuildContext context) {
    final currentItem = widget.items[_currentIndex];
    final double dragAlpha = (1.0 - (_dragOffsetY.abs() / 320.0)).clamp(0.2, 1.0);
    final double dragScale = (1.0 - (_dragOffsetY.abs() / 1200.0)).clamp(0.85, 1.0);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Container(
          color: widget.backgroundColor.withValues(
            alpha: _isDragging ? dragAlpha : 1.0,
          ),
          child: Stack(
            children: [
              // Main Interactive Page View
              GestureDetector(
                onTap: _toggleOverlay,
                onVerticalDragStart: _isCurrentZoomed
                    ? null
                    : (_) {
                        setState(() {
                          _isDragging = true;
                        });
                      },
                onVerticalDragUpdate: _isCurrentZoomed
                    ? null
                    : (details) {
                        setState(() {
                          _dragOffsetY += details.delta.dy;
                        });
                      },
                onVerticalDragEnd: _isCurrentZoomed
                    ? null
                    : (details) {
                        if (_dragOffsetY.abs() > 110 ||
                            details.velocity.pixelsPerSecond.dy.abs() > 600) {
                          Navigator.of(context).pop();
                        } else {
                          setState(() {
                            _dragOffsetY = 0.0;
                            _isDragging = false;
                          });
                        }
                      },
                child: Transform.translate(
                  offset: Offset(0, _dragOffsetY),
                  child: Transform.scale(
                    scale: dragScale,
                    child: PageView.builder(
                      controller: _pageController,
                      physics: _isCurrentZoomed
                          ? const NeverScrollableScrollPhysics()
                          : const BouncingScrollPhysics(),
                      itemCount: widget.items.length,
                      onPageChanged: _onPageChanged,
                      itemBuilder: (context, index) {
                        return _buildImagePage(widget.items[index], index);
                      },
                    ),
                  ),
                ),
              ),

              // Glassmorphic Top Controls Bar
              AnimatedPositioned(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeInOut,
                top: _showOverlay ? 0 : -100,
                left: 0,
                right: 0,
                child: _buildTopBar(currentItem),
              ),

              // Glassmorphic Bottom Caption & Thumbnail Bar
              AnimatedPositioned(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeInOut,
                bottom: _showOverlay ? 0 : -160,
                left: 0,
                right: 0,
                child: _buildBottomBar(currentItem),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePage(ImageViewerItem item, int index) {
    final transformController = _getTransformationController(index);
    final quarterTurns = _rotations[index] ?? 0;

    Widget imageContent = GestureDetector(
      onDoubleTapDown: _handleDoubleTap,
      onDoubleTap: () {}, // Handled in onDoubleTapDown
      child: InteractiveViewer(
        transformationController: transformController,
        minScale: 0.8,
        maxScale: 4.5,
        clipBehavior: Clip.none,
        child: Center(
          child: RotatedBox(
            quarterTurns: quarterTurns,
            child: _buildImageWidget(item),
          ),
        ),
      ),
    );

    if (item.heroTag != null && item.heroTag!.isNotEmpty) {
      return Hero(
        tag: item.heroTag!,
        child: imageContent,
      );
    }

    return imageContent;
  }

  Widget _buildImageWidget(ImageViewerItem item) {
    final imageProvider = item.resolveImageProvider();

    return Image(
      image: imageProvider,
      fit: BoxFit.contain,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) {
          return child;
        }
        return const Center(
          child: CircularProgressIndicator(
            color: Colors.white70,
            strokeWidth: 2.5,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Center(
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.broken_image_rounded,
                  color: Color(0xFFEF4444),
                  size: 48,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Unable to load image',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.imagePath ?? 'Invalid source',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopBar(ImageViewerItem currentItem) {
    final mediaQuery = MediaQuery.of(context);
    final topPadding = mediaQuery.padding.top > 0 ? mediaQuery.padding.top : 12.0;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: EdgeInsets.fromLTRB(16, topPadding + 4, 16, 12),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.45),
            border: const Border(
              bottom: BorderSide(color: Colors.white10, width: 0.5),
            ),
          ),
          child: Row(
            children: [
              // Close / Back button
              _buildIconButton(
                icon: Icons.close_rounded,
                tooltip: 'Close',
                onPressed: () => Navigator.of(context).pop(),
              ),

              const SizedBox(width: 12),

              // Title and Subtitle / Item Counter
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (currentItem.title != null)
                      Text(
                        currentItem.title!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    Row(
                      children: [
                        if (widget.showCounter && widget.items.length > 1) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${_currentIndex + 1} / ${widget.items.length}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        if (currentItem.subtitle != null)
                          Expanded(
                            child: Text(
                              currentItem.subtitle!,
                              style: const TextStyle(
                                color: Colors.white60,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Reset Zoom
              if (_isCurrentZoomed)
                _buildIconButton(
                  icon: Icons.restart_alt_rounded,
                  tooltip: 'Reset Zoom',
                  onPressed: _resetZoom,
                ),

              // Rotate image button
              if (widget.allowRotation) ...[
                const SizedBox(width: 6),
                _buildIconButton(
                  icon: Icons.rotate_right_rounded,
                  tooltip: 'Rotate Image',
                  onPressed: _rotateImage,
                ),
              ],

              // Download callback
              if (widget.onDownload != null) ...[
                const SizedBox(width: 6),
                _buildIconButton(
                  icon: Icons.download_rounded,
                  tooltip: 'Save / Download',
                  onPressed: () => widget.onDownload!(currentItem),
                ),
              ],

              // Share callback
              if (widget.onShare != null) ...[
                const SizedBox(width: 6),
                _buildIconButton(
                  icon: Icons.share_rounded,
                  tooltip: 'Share Image',
                  onPressed: () => widget.onShare!(currentItem),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(ImageViewerItem currentItem) {
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.padding.bottom > 0
        ? mediaQuery.padding.bottom
        : 12.0;

    final hasCaption = currentItem.caption != null && currentItem.caption!.isNotEmpty;
    final hasThumbnails = widget.showThumbnails && widget.items.length > 1;

    if (!hasCaption && !hasThumbnails) {
      return const SizedBox.shrink();
    }

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: EdgeInsets.fromLTRB(16, 12, 16, bottomPadding + 6),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            border: const Border(
              top: BorderSide(color: Colors.white10, width: 0.5),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Caption Text
              if (hasCaption) ...[
                Text(
                  currentItem.caption!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                if (hasThumbnails) const SizedBox(height: 12),
              ],

              // Thumbnail Carousel Strip
              if (hasThumbnails)
                SizedBox(
                  height: 48,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.items.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final isSelected = index == _currentIndex;
                      final item = widget.items[index];

                      return GestureDetector(
                        onTap: () {
                          _pageController.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF38BDF8)
                                  : Colors.white24,
                              width: isSelected ? 2.0 : 1.0,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image(
                              image: item.resolveImageProvider(),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: const Color(0xFF334155),
                                child: const Icon(
                                  Icons.image_not_supported_rounded,
                                  color: Colors.white38,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.white.withValues(alpha: 0.12),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 20),
        tooltip: tooltip,
        onPressed: onPressed,
        constraints: const BoxConstraints(
          minWidth: 36,
          minHeight: 36,
        ),
        padding: EdgeInsets.zero,
      ),
    );
  }
}
