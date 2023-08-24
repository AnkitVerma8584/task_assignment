import 'dart:typed_data';
import 'package:black_coffer/pages/post/post_screen.dart';
import 'package:cached_video_preview/cached_video_preview.dart';
import 'package:flutter/material.dart';
import '../../../models/post.dart';

class PostCard extends StatelessWidget {
  const PostCard({super.key, required this.post});
  final Post post;

  @override
  Widget build(BuildContext context) {
    Uint8List? thumbNail;
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => PostScreen(post: post, thumb: thumbNail)));
      },
      child: Card(
        child: SizedBox(
          height: 140,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: SizedBox(
                    height: 140,
                    width: 120,
                    child: Stack(children: [
                      Hero(
                        tag: post.videoUrl,
                        child: CachedVideoPreviewWidget(
                          path: post.videoUrl,
                          placeHolder:
                              Image.asset("assets/images/loading_failed.png"),
                          type: SourceType.remote,
                          fileImageBuilder: (context, bytes) {
                            thumbNail = bytes;
                            return Image.memory(
                              bytes,
                              height: 120,
                              width: 120,
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      ),
                      const Center(
                        child: Icon(
                          Icons.videocam,
                          color: Colors.white,
                        ),
                      )
                    ]),
                  ),
                ),
              ),
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.videoTitle,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      post.videoDescription,
                      maxLines: 2,
                      style: const TextStyle(color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      post.videoCategory,
                      maxLines: 1,
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    )
                  ],
                ),
              ))
            ],
          ),
        ),
      ),
    );
  }
}
