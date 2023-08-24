import 'dart:typed_data';
import 'package:black_coffer/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../models/post.dart';
import 'package:chewie/chewie.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key, required this.post, required this.thumb});
  final Post post;
  final Uint8List? thumb;
  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  late VideoPlayerController _controller;
  late ChewieController _chewieController;

  @override
  void initState() {
    super.initState();
    _controller =
        VideoPlayerController.networkUrl(Uri.parse(widget.post.videoUrl))
          ..initialize().then((_) {
            setState(() {
              _chewieController = ChewieController(
                  videoPlayerController: _controller,
                  showOptions: false,
                  allowFullScreen: false,
                  aspectRatio: _controller.value.aspectRatio);
            });
          });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _chewieController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: SingleChildScrollView(
          child: Column(children: [
            SizedBox(
              height: height * 0.7,
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: _controller.value.isInitialized
                    ? Chewie(controller: _chewieController)
                    : Stack(
                        children: [
                          if (widget.thumb != null)
                            Hero(
                              tag: widget.post.videoUrl,
                              child: Center(child: Image.memory(widget.thumb!)),
                            ),
                          const Center(child: CircularProgressIndicator())
                        ],
                      ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
              child: Text(
                widget.post.videoTitle,
                style:
                    const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.thumb_up),
                        iconSize: 18,
                      ),
                      const Text("250 likes")
                    ],
                  ),
                  const SizedBox(width: 10),
                  Column(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.thumb_down),
                        iconSize: 18,
                      ),
                      const Text("2 days ago")
                    ],
                  ),
                  const SizedBox(width: 10),
                  Column(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.share),
                        iconSize: 18,
                      ),
                      Text(widget.post.videoCategory)
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                widget.post.videoDescription,
                textAlign: TextAlign.start,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const SizedBox(width: 10),
                Icon(Icons.location_pin,
                    size: 18, color: getColors(context).error),
                const SizedBox(width: 5),
                Text(widget.post.videoLocation),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                const SizedBox(width: 16),
                const CircleAvatar(
                  radius: 12,
                  child: Center(child: Icon(Icons.person_2)),
                ),
                const SizedBox(width: 10),
                const Text("Random user", textScaleFactor: 1.5),
                const Spacer(),
                TextButton(
                    onPressed: () {},
                    child: const Text(
                      "View all",
                      style: TextStyle(color: Colors.blue),
                    )),
                const SizedBox(width: 8),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(16),
              alignment: Alignment.centerLeft,
              child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.comment, size: 15),
                  label: const Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Text(
                      "Comment",
                      textScaleFactor: 1.2,
                    ),
                  )),
            )
          ]),
        ),
      ),
    );
  }
}













/*import 'dart:typed_data';
import 'package:black_coffer/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../models/post.dart';
import 'package:chewie/chewie.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key, required this.post, required this.thumb});
  final Post post;
  final Uint8List? thumb;
  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  late VideoPlayerController _controller;
  late ChewieController _chewieController;
  double videoOffset = 0;
  @override
  void initState() {
    super.initState();
    _controller =
        VideoPlayerController.networkUrl(Uri.parse(widget.post.videoUrl))
          ..initialize().then((_) {
            setState(() {
              _chewieController = ChewieController(
                  videoPlayerController: _controller,
                  showOptions: false,
                  allowFullScreen: false,
                  aspectRatio: _controller.value.aspectRatio);
            });
          });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _chewieController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        body: NotificationListener(
          onNotification: (notif) {
            if (notif is ScrollUpdateNotification) {
              if (notif.scrollDelta == null) return true;
              setState(() {
                videoOffset -= notif.scrollDelta! / 1.9;
              });
            }
            return true;
          },
          child: Stack(children: [
            Positioned(
              top: videoOffset,
              left: 0,
              right: 0,
              child: SizedBox(
                height: height * 0.7,
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: _controller.value.isInitialized
                      ? Chewie(controller: _chewieController)
                      : Stack(
                          children: [
                            if (widget.thumb != null)
                              Hero(
                                tag: widget.post.videoUrl,
                                child:
                                    Center(child: Image.memory(widget.thumb!)),
                              ),
                            const Center(child: CircularProgressIndicator())
                          ],
                        ),
                ),
              ),
            ),
            SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                children: [
                  SizedBox(height: height * 0.7),
                  Container(
                    height: height,
                    color: getColors(context).background,
                    child: Column(
                      children: [
                        Text(widget.post.videoTitle),
                        Text(widget.post.videoDescription),
                        Text(widget.post.videoCategory),
                        Text(widget.post.videoLocation),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ]),
        ),
      ),
    );
  }
}
 */