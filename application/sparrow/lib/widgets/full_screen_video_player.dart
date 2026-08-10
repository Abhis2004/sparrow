import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

/// Full-screen interactive video player modal widget supporting local files,
/// network URLs, and Flutter assets with full playback controls, seek slider,
/// volume controls, playback speed selection, and double-tap seeking.
class FullScreenVideoPlayer extends StatefulWidget {
  final String videoPath;
  final String? title;
  final String? subtitle;
  final String? caption;
  final Color backgroundColor;
  final bool autoPlay;

  const FullScreenVideoPlayer({
    super.key,
    required this.videoPath,
    this.title,
    this.subtitle,
    this.caption,
    this.backgroundColor = const Color(0xFF090D16),
    this.autoPlay = true,
  });

  /// Convenience static method to open the video player in a full-screen route.
  static Future<T?> open<T>(
    BuildContext context, {
    required String videoPath,
    String? title,
    String? subtitle,
    String? caption,
    bool autoPlay = true,
    Color backgroundColor = const Color(0xFF090D16),
  }) {
    return Navigator.of(context).push<T>(
      PageRouteBuilder<T>(
        opaque: false,
        barrierColor: Colors.black.withValues(alpha: 0.9),
        barrierDismissible: true,
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: FullScreenVideoPlayer(
              videoPath: videoPath,
              title: title,
              subtitle: subtitle,
              caption: caption,
              autoPlay: autoPlay,
              backgroundColor: backgroundColor,
            ),
          );
        },
      ),
    );
  }

  @override
  State<FullScreenVideoPlayer> createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  String _errorMessage = '';

  bool _showControls = true;
  Timer? _hideTimer;

  double _playbackSpeed = 1.0;
  bool _isMuted = false;
  double _volumeBeforeMute = 1.0;

  // Double tap seek animation indicators
  bool _showRewindIndicator = false;
  bool _showForwardIndicator = false;
  Timer? _indicatorTimer;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      final path = widget.videoPath.trim();
      if (path.isEmpty) {
        throw Exception('Video file path is empty');
      }

      if (path.startsWith('http://') || path.startsWith('https://')) {
        _controller = VideoPlayerController.networkUrl(Uri.parse(path));
      } else if (path.startsWith('assets/') || path.startsWith('asset:')) {
        final cleanPath = path.startsWith('asset:') ? path.substring(6) : path;
        _controller = VideoPlayerController.asset(cleanPath);
      } else {
        final file = File(path);
        if (!file.existsSync()) {
          throw Exception('Video file does not exist at location: $path');
        }
        _controller = VideoPlayerController.file(file);
      }

      await _controller!.initialize();
      _controller!.addListener(_onControllerListener);

      if (widget.autoPlay) {
        await _controller!.play();
      }

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        _startHideTimer();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  void _onControllerListener() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _indicatorTimer?.cancel();
    if (_controller != null) {
      _controller!.removeListener(_onControllerListener);
      _controller!.dispose();
    }
    super.dispose();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _controller != null && _controller!.value.isPlaying) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls) {
      _startHideTimer();
    }
  }

  void _togglePlayPause() {
    if (_controller == null || !_isInitialized) return;
    setState(() {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
        _showControls = true;
        _hideTimer?.cancel();
      } else {
        _controller!.play();
        _startHideTimer();
      }
    });
  }

  void _seekRelative(int seconds) {
    if (_controller == null || !_isInitialized) return;
    final currentPos = _controller!.value.position;
    final newPos = currentPos + Duration(seconds: seconds);
    final maxPos = _controller!.value.duration;
    Duration clampedPos = newPos;
    if (clampedPos < Duration.zero) {
      clampedPos = Duration.zero;
    } else if (clampedPos > maxPos) {
      clampedPos = maxPos;
    }
    _controller!.seekTo(clampedPos);

    setState(() {
      if (seconds < 0) {
        _showRewindIndicator = true;
        _showForwardIndicator = false;
      } else {
        _showForwardIndicator = true;
        _showRewindIndicator = false;
      }
    });

    _indicatorTimer?.cancel();
    _indicatorTimer = Timer(const Duration(milliseconds: 700), () {
      if (mounted) {
        setState(() {
          _showRewindIndicator = false;
          _showForwardIndicator = false;
        });
      }
    });

    _startHideTimer();
  }

  void _toggleMute() {
    if (_controller == null || !_isInitialized) return;
    setState(() {
      if (_isMuted) {
        _controller!.setVolume(_volumeBeforeMute);
        _isMuted = false;
      } else {
        _volumeBeforeMute = _controller!.value.volume > 0 ? _controller!.value.volume : 1.0;
        _controller!.setVolume(0.0);
        _isMuted = true;
      }
    });
  }

  void _setPlaybackSpeed(double speed) {
    if (_controller == null || !_isInitialized) return;
    setState(() {
      _playbackSpeed = speed;
      _controller!.setPlaybackSpeed(speed);
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Container(
          color: widget.backgroundColor,
          child: Stack(
            children: [
              // Main Video Content
              Center(
                child: _buildVideoContent(),
              ),

              // Double-Tap Gesture Zones (Left = -10s, Right = +10s)
              Positioned.fill(
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: _toggleControls,
                        onDoubleTap: () => _seekRelative(-10),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: _toggleControls,
                        onDoubleTap: () => _seekRelative(10),
                      ),
                    ),
                  ],
                ),
              ),

              // Rewind / Fast Forward Badge Indicators
              if (_showRewindIndicator)
                Center(
                  child: Align(
                    alignment: const Alignment(-0.5, 0.0),
                    child: _buildSeekBadge('-10s', Icons.replay_10_rounded),
                  ),
                ),
              if (_showForwardIndicator)
                Center(
                  child: Align(
                    alignment: const Alignment(0.5, 0.0),
                    child: _buildSeekBadge('+10s', Icons.forward_10_rounded),
                  ),
                ),

              // Center Big Play/Pause Button
              if (_showControls && _isInitialized && !_hasError)
                Center(
                  child: _buildCenterPlayPauseButton(),
                ),

              // Top Glassmorphic Controls Bar
              AnimatedPositioned(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeInOut,
                top: _showControls ? 0 : -100,
                left: 0,
                right: 0,
                child: _buildTopBar(),
              ),

              // Bottom Glassmorphic Controls Bar
              AnimatedPositioned(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeInOut,
                bottom: _showControls ? 0 : -140,
                left: 0,
                right: 0,
                child: _buildBottomBar(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoContent() {
    if (_hasError) {
      return Container(
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
              Icons.video_camera_back_outlined,
              color: Color(0xFFEF4444),
              size: 52,
            ),
            const SizedBox(height: 12),
            const Text(
              'Unable to play video',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _errorMessage,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _hasError = false;
                  _isInitialized = false;
                });
                _initializeVideo();
              },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (!_isInitialized || _controller == null) {
      return const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color: Colors.white70,
            strokeWidth: 2.5,
          ),
          SizedBox(height: 16),
          Text(
            'Loading Video...',
            style: TextStyle(color: Colors.white60, fontSize: 13),
          ),
        ],
      );
    }

    return AspectRatio(
      aspectRatio: _controller!.value.aspectRatio,
      child: Stack(
        alignment: Alignment.center,
        children: [
          VideoPlayer(_controller!),
          if (_controller!.value.isBuffering)
            const CircularProgressIndicator(
              color: Colors.white70,
              strokeWidth: 2.5,
            ),
        ],
      ),
    );
  }

  Widget _buildCenterPlayPauseButton() {
    final isPlaying = _controller?.value.isPlaying ?? false;
    return GestureDetector(
      onTap: _togglePlayPause,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.55),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24, width: 1.5),
        ),
        child: Icon(
          isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
          color: Colors.white,
          size: 44,
        ),
      ),
    );
  }

  Widget _buildSeekBadge(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFF38BDF8), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF38BDF8), size: 24),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
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
              // Close button
              _buildIconButton(
                icon: Icons.close_rounded,
                tooltip: 'Close',
                onPressed: () => Navigator.of(context).pop(),
              ),

              const SizedBox(width: 12),

              // Title and Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.title ?? 'Video Evidence',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (widget.subtitle != null)
                      Text(
                        widget.subtitle!,
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),

              // Playback Speed Selector
              PopupMenuButton<double>(
                tooltip: 'Playback Speed',
                initialValue: _playbackSpeed,
                color: const Color(0xFF1E293B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: _setPlaybackSpeed,
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 0.5, child: Text('0.5x Speed', style: TextStyle(color: Colors.white))),
                  PopupMenuItem(value: 1.0, child: Text('1.0x (Normal)', style: TextStyle(color: Colors.white))),
                  PopupMenuItem(value: 1.25, child: Text('1.25x Speed', style: TextStyle(color: Colors.white))),
                  PopupMenuItem(value: 1.5, child: Text('1.5x Speed', style: TextStyle(color: Colors.white))),
                  PopupMenuItem(value: 2.0, child: Text('2.0x Speed', style: TextStyle(color: Colors.white))),
                ],
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${_playbackSpeed}x',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Mute / Unmute Button
              _buildIconButton(
                icon: _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                tooltip: _isMuted ? 'Unmute' : 'Mute',
                onPressed: _toggleMute,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.padding.bottom > 0
        ? mediaQuery.padding.bottom
        : 12.0;

    final position = _controller?.value.position ?? Duration.zero;
    final duration = _controller?.value.duration ?? Duration.zero;

    final progressRatio = duration.inMilliseconds > 0
        ? (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: EdgeInsets.fromLTRB(16, 10, 16, bottomPadding + 6),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            border: const Border(
              top: BorderSide(color: Colors.white10, width: 0.5),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Caption / Description
              if (widget.caption != null && widget.caption!.isNotEmpty) ...[
                Text(
                  widget.caption!,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
              ],

              // Slider & Controls Row
              Row(
                children: [
                  // Play / Pause mini button
                  IconButton(
                    icon: Icon(
                      (_controller?.value.isPlaying ?? false)
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    onPressed: _togglePlayPause,
                  ),

                  // -10s Rewind
                  IconButton(
                    icon: const Icon(Icons.replay_10_rounded, color: Colors.white70, size: 20),
                    onPressed: () => _seekRelative(-10),
                  ),

                  // Time indicator
                  Text(
                    '${_formatDuration(position)} / ${_formatDuration(duration)}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Interactive Progress Slider
                  Expanded(
                    child: SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 3,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                        activeTrackColor: const Color(0xFF38BDF8),
                        inactiveTrackColor: Colors.white24,
                        thumbColor: const Color(0xFF38BDF8),
                        overlayColor: const Color(0xFF38BDF8).withValues(alpha: 0.2),
                      ),
                      child: Slider(
                        value: progressRatio,
                        onChanged: (value) {
                          if (_controller == null || !_isInitialized) return;
                          final targetMs = (value * duration.inMilliseconds).toInt();
                          _controller!.seekTo(Duration(milliseconds: targetMs));
                          _startHideTimer();
                        },
                      ),
                    ),
                  ),

                  // +10s Fast forward
                  IconButton(
                    icon: const Icon(Icons.forward_10_rounded, color: Colors.white70, size: 20),
                    onPressed: () => _seekRelative(10),
                  ),
                ],
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
