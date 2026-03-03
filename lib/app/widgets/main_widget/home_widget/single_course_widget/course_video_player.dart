import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:webinar/common/utils/date_formater.dart';
import 'package:webinar/common/utils/download_manager.dart';
import 'package:webinar/config/assets.dart';
import 'package:webinar/config/colors.dart';
import 'package:webinar/config/styles.dart';

import '../../../../../common/common.dart';

class CourseVideoPlayer extends StatefulWidget {
  final String url;
  final String imageCover;

  final bool isLoadNetwork;
  final String? localFileName;
  final RouteObserver<ModalRoute<void>> routeObserver;

  const CourseVideoPlayer(this.url, this.imageCover, this.routeObserver,
      {this.isLoadNetwork = true, this.localFileName, super.key});

  @override
  State<CourseVideoPlayer> createState() => _CourseVideoPlayerState();
}

class _CourseVideoPlayerState extends State<CourseVideoPlayer>
    with RouteAware {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isPlaying = true;

  Duration videoDuration = const Duration(seconds: 0);
  Duration videoPosition = const Duration(seconds: 0);

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    widget.routeObserver.unsubscribe(this);
    _controller?.removeListener(_listener);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didPush() {}

  @override
  void didPushNext() {
    _controller?.pause();
  }

  @override
  void didPopNext() {
    _controller?.play();
  }

  void _listener() {
    if (!mounted || _controller == null) return;
    final pos = _controller!.value.position;
    final dur = _controller!.value.duration;
    final playing = _controller!.value.isPlaying;
    if (videoPosition.inSeconds != pos.inSeconds ||
        videoDuration.inSeconds != dur.inSeconds ||
        _isPlaying != playing) {
      setState(() {
        videoPosition = pos;
        videoDuration = dur;
        _isPlaying = playing;
      });
    }
  }

  Future<void> _initVideo() async {
    if (widget.url.trim().isEmpty && (widget.localFileName == null || widget.localFileName!.trim().isEmpty)) {
      return;
    }
    try {
      if (widget.isLoadNetwork) {
        _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url));
      } else {
        String directory = (await getApplicationSupportDirectory()).path;
        bool isExistFile = await DownloadManager.findFile(
            directory, widget.localFileName!,
            isOpen: false);
        if (isExistFile) {
          _controller = VideoPlayerController.file(
            File('$directory/${widget.localFileName}'),
          );
        }
      }
      if (_controller == null) return;
      _controller!.addListener(_listener);
      await _controller!.initialize();
      if (!mounted) return;
      videoDuration = _controller!.value.duration;
      setState(() {
        _isInitialized = true;
        _isPlaying = true;
      });
      _controller!.play();
    } catch (e) {
      if (mounted) setState(() => _isInitialized = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: borderRadius(),
          child: Column(
            children: [
              AspectRatio(
                aspectRatio: 16 / 9.0,
                child: _isInitialized && _controller != null
                    ? VideoPlayer(_controller!)
                    : Container(
                        color: Colors.black26,
                        alignment: Alignment.center,
                        child: const CircularProgressIndicator(),
                      ),
              ),
            ],
          ),
        ),
        space(12),
        AnimatedCrossFade(
          firstChild: Container(
            padding: padding(horizontal: 16, vertical: 16),
            width: getSize().width,
            decoration: BoxDecoration(
              color: whiteFF_26,
              borderRadius: borderRadius(),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (_controller == null) return;
                        if (_isPlaying) {
                          _controller!.pause();
                        } else {
                          _controller!.play();
                        }
                        setState(() => _isPlaying = !_isPlaying);
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: greyB2),
                        ),
                        child: Icon(
                          !_isPlaying ? Icons.play_arrow_rounded : Icons.pause,
                          size: 17,
                          color: greyB2,
                        ),
                      ),
                    ),
                    space(0, width: 16),
                    Text(
                      '${secondDurationToString(videoPosition.inSeconds)} / ${secondDurationToString(videoDuration.inSeconds)}',
                      style: style12Regular().copyWith(color: greyB2),
                    ),
                  ],
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (_controller == null) return;
                        final vol = _controller!.value.volume;
                        _controller!.setVolume(vol > 0 ? 0.0 : 1.0);
                        setState(() {});
                      },
                      behavior: HitTestBehavior.opaque,
                      child: SvgPicture.asset(
                        (_controller?.value.volume ?? 1.0) > 0
                            ? AppAssets.soundOnSvg
                            : AppAssets.soundOffSvg,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          secondChild: SizedBox(width: getSize().width),
          crossFadeState: CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
        ),
      ],
    );
  }
}
