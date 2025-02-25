import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen(this.url, {super.key});
  final String url;
  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  bool isLoading = true;
  late final player = Player();
  late final controller = VideoController(player);

  Future<void> initializePlayer() async {}
  init() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    player.open(Media(widget.url));
    setState(() => isLoading = false);
  }

  @override
  void initState() {
    super.initState();

    init();
  }

  @override
  void dispose() async {
    await player.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : MaterialVideoControlsTheme(
                normal: MaterialVideoControlsThemeData(
                  buttonBarButtonSize: 24.0,
                  buttonBarButtonColor: Colors.white,
                  seekBarPositionColor: Colors.red,
                  seekBarContainerHeight: 50,
                  seekBarThumbColor: Colors.red,
                  seekBarMargin: EdgeInsets.only(bottom: 50),
                  seekBarThumbSize: 15,
                  seekBarHeight: 15,
                  
                ),
                fullscreen: const MaterialVideoControlsThemeData(
                  seekBarContainerHeight: 50,
                  seekBarThumbColor: Colors.red,
                  seekBarMargin: EdgeInsets.only(bottom: 50),
                  seekBarThumbSize: 15,
                  seekBarHeight: 15,
                ),
                child: Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.width * 9.0 / 16.0,
                    child: Video(
                      controller: controller,
                      controls: MaterialVideoControls,
                    ),
                  ),
                ),
              ),
    );
  }
}
