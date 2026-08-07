import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:enki/core/themes/app_colors.dart';

class VideoPlayerPage extends StatefulWidget {
  final String url;
  final String title;

  const VideoPlayerPage({
    super.key,
    required this.url,
    required this.title,
  });

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late final Player _player;
  late final VideoController _controller;

  @override
  void initState() {
    super.initState();
    _player = Player();
    _controller = VideoController(_player);
    _player.open(Media(widget.url));

    // Mobile UX: Start in portrait, but allow landscape if they rotate the phone manually
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    // Always force portrait when leaving the player
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _player.dispose();
    super.dispose();
  }

  // A reusable header that looks good in both portrait and landscape
  List<Widget> _buildTopBar() {
    return [
    BackButton(color: Colors.white), // Handles fullscreen exit automatically
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // SafeArea ensures we don't draw under the notch in portrait mode
      body: SafeArea(
        child: MaterialVideoControlsTheme(
          normal: MaterialVideoControlsThemeData(
            // 1. Mobile UX: Giant play button in the center
            primaryButtonBar: [
              const Spacer(),
              MaterialPlayOrPauseButton(
                iconSize: 56,
                iconColor: Colors.white.withOpacity(0.9),
              ),
              const Spacer(),
            ],
            // 2. Immersive UI: Title sits inside the video overlay
            topButtonBar: _buildTopBar(),
            topButtonBarMargin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            
            // 3. Fat-finger friendly seek bar
            seekBarThumbColor: AppColors.enkiMain,
            seekBarPositionColor: AppColors.enkiMain,
            seekBarBufferColor: Colors.white24,
            seekBarContainerHeight: 40,
            seekBarThumbSize: 16,
            seekBarMargin: const EdgeInsets.symmetric(horizontal: 16),
            
            buttonBarHeight: 60,
            controlsHoverDuration: const Duration(seconds: 3),
            
            bottomButtonBar: [
              const MaterialPositionIndicator(),
              const Spacer(),
              const MaterialFullscreenButton(), // Taps into landscape automatically
            ],
          ),
          fullscreen: MaterialVideoControlsThemeData(
            // Fullscreen gets the same controls, but optimized for landscape
            primaryButtonBar: [
              const Spacer(),
              MaterialPlayOrPauseButton(
                iconSize: 64, // Even bigger in landscape
                iconColor: Colors.white.withOpacity(0.9),
              ),
              const Spacer(),
            ],
            topButtonBar: _buildTopBar(),
            topButtonBarMargin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            
            seekBarThumbColor: AppColors.enkiMain,
            seekBarPositionColor: AppColors.enkiMain,
            seekBarBufferColor: Colors.white24,
            seekBarContainerHeight: 48, // Taller hit-box for landscape
            seekBarThumbSize: 20,
            seekBarMargin: const EdgeInsets.symmetric(horizontal: 24),
            
            buttonBarHeight: 80,
            controlsHoverDuration: const Duration(seconds: 4), // Keep controls up a bit longer
            
            bottomButtonBar: [
              const MaterialSkipPreviousButton(),
              const MaterialSkipNextButton(),
              const SizedBox(width: 8),
              const MaterialPositionIndicator(),
              const Spacer(),
              const MaterialFullscreenButton(),
            ],
          ),
          child: Video(
            controller: _controller,
            fit: BoxFit.contain,
            // 4. Enable Native Mobile Gestures
            controls: MaterialVideoControls, 
          ),
        ),
      ),
    );
  }
}
