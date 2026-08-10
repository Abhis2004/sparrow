import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Full-screen interactive audio player modal widget supporting local files,
/// network URLs, and Flutter assets with full playback controls, animated waveform,
/// seek slider, volume control, and playback speed selection.
class FullScreenAudioPlayer extends StatefulWidget {
  final String audioPath;
  final String? title;
  final String? subtitle;
  final String? caption;
  final Color backgroundColor;
  final bool autoPlay;

  const FullScreenAudioPlayer({
    super.key,
    required this.audioPath,
    this.title,
    this.subtitle,
    this.caption,
    this.backgroundColor = const Color(0xFF090D16),
    this.autoPlay = true,
  });

  /// Convenience static method to open the audio player in a modal route.
  static Future<T?> open<T>(
    BuildContext context, {
    required String audioPath,
    String? title,
    String? subtitle,
    String? caption,
    bool autoPlay = true,
    Color backgroundColor = const Color(0xFF090D16),
  }) {
    return Navigator.of(context).push<T>(
      PageRouteBuilder<T>(
        opaque: false,
        barrierColor: Colors.black.withValues(alpha: 0.85),
        barrierDismissible: true,
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: FullScreenAudioPlayer(
              audioPath: audioPath,
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
  State<FullScreenAudioPlayer> createState() => _FullScreenAudioPlayerState();
}

class _FullScreenAudioPlayerState extends State<FullScreenAudioPlayer>
    with SingleTickerProviderStateMixin {
  late AudioPlayer _audioPlayer;
  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _durationSubscription;

  PlayerState _playerState = PlayerState.stopped;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  bool _isInitialized = false;
  bool _hasError = false;
  String _errorMessage = '';

  double _playbackSpeed = 1.0;
  bool _isMuted = false;
  double _volumeBeforeMute = 1.0;

  late AnimationController _waveAnimController;

  @override
  void initState() {
    super.initState();
    _waveAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _initializeAudio();
  }

  Future<void> _initializeAudio() async {
    try {
      _audioPlayer = AudioPlayer();

      _playerStateSubscription = _audioPlayer.onPlayerStateChanged.listen((state) {
        if (mounted) {
          setState(() {
            _playerState = state;
          });
          if (state == PlayerState.playing) {
            _waveAnimController.repeat(reverse: true);
          } else {
            _waveAnimController.stop();
          }
        }
      });

      _positionSubscription = _audioPlayer.onPositionChanged.listen((pos) {
        if (mounted) {
          setState(() {
            _position = pos;
          });
        }
      });

      _durationSubscription = _audioPlayer.onDurationChanged.listen((dur) {
        if (mounted) {
          setState(() {
            _duration = dur;
          });
        }
      });

      final path = widget.audioPath.trim();
      if (path.isEmpty) {
        throw Exception('Audio file path is empty');
      }

      Source source;
      if (path.startsWith('http://') || path.startsWith('https://')) {
        source = UrlSource(path);
      } else if (path.startsWith('assets/') || path.startsWith('asset:')) {
        final cleanPath = path.startsWith('asset:') ? path.substring(6) : path;
        source = AssetSource(cleanPath);
      } else {
        final file = File(path);
        if (!file.existsSync()) {
          throw Exception('Audio file does not exist at location: $path');
        }
        source = DeviceFileSource(path);
      }

      await _audioPlayer.setSource(source);

      if (widget.autoPlay) {
        await _audioPlayer.resume();
      }

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
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

  @override
  void dispose() {
    _waveAnimController.dispose();
    _playerStateSubscription?.cancel();
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  bool get _isPlaying => _playerState == PlayerState.playing;

  Future<void> _togglePlayPause() async {
    if (!_isInitialized || _hasError) return;
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.resume();
    }
  }

  Future<void> _seekRelative(int seconds) async {
    if (!_isInitialized || _hasError) return;
    final targetMs = _position.inMilliseconds + (seconds * 1000);
    final clampedMs = targetMs.clamp(0, _duration.inMilliseconds > 0 ? _duration.inMilliseconds : 0);
    await _audioPlayer.seek(Duration(milliseconds: clampedMs));
  }

  Future<void> _toggleMute() async {
    if (!_isInitialized || _hasError) return;
    if (_isMuted) {
      await _audioPlayer.setVolume(_volumeBeforeMute);
      setState(() {
        _isMuted = false;
      });
    } else {
      _volumeBeforeMute = 1.0;
      await _audioPlayer.setVolume(0.0);
      setState(() {
        _isMuted = true;
      });
    }
  }

  Future<void> _setSpeed(double speed) async {
    if (!_isInitialized || _hasError) return;
    await _audioPlayer.setPlaybackRate(speed);
    setState(() {
      _playbackSpeed = speed;
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
          child: SafeArea(
            child: Stack(
              children: [
                // Main Content Column
                Column(
                  children: [
                    // Top Bar
                    _buildTopBar(),

                    // Main Visualizer & Info Area
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Glowing Circular Album / Audio Icon
                            _buildAudioArtIcon(),

                            const SizedBox(height: 32),

                            // Animated Waveform Visualizer
                            _buildWaveformVisualizer(),

                            const SizedBox(height: 28),

                            // Title & Subtitle
                            Text(
                              widget.title ?? 'Audio Recording',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (widget.subtitle != null) ...[
                              const SizedBox(height: 6),
                              Text(
                                widget.subtitle!,
                                style: const TextStyle(
                                  color: Color(0xFF38BDF8),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                            if (widget.caption != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                widget.caption!,
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    // Bottom Controls Bar
                    _buildBottomControls(),
                  ],
                ),

                // Error View Overlay if any
                if (_hasError)
                  Center(
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
                            Icons.audiotrack_rounded,
                            color: Color(0xFFEF4444),
                            size: 52,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Unable to play audio',
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
                              _initializeAudio();
                            },
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            label: const Text('Retry'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFEA580C),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Close button
          _buildIconButton(
            icon: Icons.close_rounded,
            tooltip: 'Close',
            onPressed: () => Navigator.of(context).pop(),
          ),

          const Spacer(),

          // Audio Evidence Tag Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFEA580C).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFEA580C).withValues(alpha: 0.5)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.mic_rounded, size: 14, color: Color(0xFFFB923C)),
                SizedBox(width: 6),
                Text(
                  'AUDIO EVIDENCE',
                  style: TextStyle(
                    color: Color(0xFFFB923C),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Mute / Unmute Button
          _buildIconButton(
            icon: _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
            tooltip: _isMuted ? 'Unmute' : 'Mute',
            onPressed: _toggleMute,
          ),
        ],
      ),
    );
  }

  Widget _buildAudioArtIcon() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: _isPlaying ? 130 : 110,
      height: _isPlaying ? 130 : 110,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFFC2410C), Color(0xFFEA580C), Color(0xFFF97316)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEA580C).withValues(alpha: _isPlaying ? 0.5 : 0.2),
            blurRadius: _isPlaying ? 32 : 16,
            spreadRadius: _isPlaying ? 8 : 2,
          ),
        ],
      ),
      child: const Center(
        child: Icon(
          Icons.graphic_eq_rounded,
          color: Colors.white,
          size: 54,
        ),
      ),
    );
  }

  Widget _buildWaveformVisualizer() {
    const int barCount = 18;
    return AnimatedBuilder(
      animation: _waveAnimController,
      builder: (context, child) {
        return SizedBox(
          height: 48,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(barCount, (index) {
              final phase = (index / barCount) * math.pi * 2;
              final animValue = _isPlaying
                  ? (math.sin((_waveAnimController.value * math.pi * 2) + phase).abs())
                  : 0.15;
              final barHeight = (12.0 + (animValue * 32.0)).clamp(8.0, 48.0);

              return Container(
                width: 4,
                height: barHeight,
                margin: const EdgeInsets.symmetric(horizontal: 2.5),
                decoration: BoxDecoration(
                  color: _isPlaying
                      ? (index % 2 == 0 ? const Color(0xFF38BDF8) : const Color(0xFFFB923C))
                      : Colors.white24,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildBottomControls() {
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.padding.bottom > 0 ? mediaQuery.padding.bottom : 16.0;

    final progressRatio = _duration.inMilliseconds > 0
        ? (_position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, bottomPadding + 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: const Border(
          top: BorderSide(color: Colors.white10, width: 0.5),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Scrub Slider & Timestamps
          Column(
            children: [
              SliderTheme(
                data: SliderThemeData(
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                  activeTrackColor: const Color(0xFFFB923C),
                  inactiveTrackColor: Colors.white24,
                  thumbColor: const Color(0xFFFB923C),
                  overlayColor: const Color(0xFFFB923C).withValues(alpha: 0.2),
                ),
                child: Slider(
                  value: progressRatio,
                  onChanged: (value) async {
                    if (!_isInitialized || _hasError) return;
                    final targetMs = (value * _duration.inMilliseconds).toInt();
                    await _audioPlayer.seek(Duration(milliseconds: targetMs));
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(_position),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      _formatDuration(_duration),
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Main Controls Row (Speed, Rewind, Play/Pause, Fast-Forward, Loop)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Speed selector
              PopupMenuButton<double>(
                tooltip: 'Playback Speed',
                initialValue: _playbackSpeed,
                color: const Color(0xFF1E293B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: _setSpeed,
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

              // -10s Rewind
              IconButton(
                icon: const Icon(Icons.replay_10_rounded, color: Colors.white, size: 30),
                tooltip: 'Rewind 10s',
                onPressed: () => _seekRelative(-10),
              ),

              // Center Play/Pause Floating Action Button
              GestureDetector(
                onTap: _togglePlayPause,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFEA580C),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFFEA580C),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 38,
                  ),
                ),
              ),

              // +10s Fast forward
              IconButton(
                icon: const Icon(Icons.forward_10_rounded, color: Colors.white, size: 30),
                tooltip: 'Fast Forward 10s',
                onPressed: () => _seekRelative(10),
              ),

              // Replay / Restart button
              IconButton(
                icon: const Icon(Icons.restart_alt_rounded, color: Colors.white70, size: 24),
                tooltip: 'Restart',
                onPressed: () => _seekRelative(-_position.inSeconds),
              ),
            ],
          ),
        ],
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
          minWidth: 40,
          minHeight: 40,
        ),
        padding: EdgeInsets.zero,
      ),
    );
  }
}
