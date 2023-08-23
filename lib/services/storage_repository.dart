import 'dart:async';
import 'dart:io';
import 'package:black_coffer/models/video_upload.dart';
import 'package:black_coffer/services/firestore_repository.dart';
import 'package:black_coffer/util/common.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/post.dart';

final storageRef = FirebaseStorage.instance.ref();

void uploadVideoStream({
  required File file,
  required String uid,
  required String title,
  required String description,
  required String category,
  required String location,
  required StreamController<VideoUpload> streamController,
}) {
  final child = "VID:$getTimeStamp()";
  final videoRef = storageRef.child(uid).child(child);
  try {
    final uploadTask =
        videoRef.putFile(file, SettableMetadata(contentType: "video/mp4"));

    uploadTask.snapshotEvents.listen((TaskSnapshot taskSnapshot) async {
      switch (taskSnapshot.state) {
        case TaskState.running:
          final progress =
              100.0 * (taskSnapshot.bytesTransferred / taskSnapshot.totalBytes);
          streamController
              .add(VideoUpload(progress, false, false, false, null));
          break;
        case TaskState.paused:
          streamController.add(VideoUpload(0, false, true, false, null));
          break;
        case TaskState.canceled:
          streamController.add(VideoUpload(0, false, false, true, null));
          break;
        case TaskState.error:
          streamController.add(VideoUpload(0, true, false, false, null));
          break;
        case TaskState.success:
          var url = await taskSnapshot.ref.getDownloadURL();
          Post post = Post(
            userId: uid,
            videoTitle: title,
            videoDescription: description,
            videoUrl: url,
            videoLocation: location,
          );
          await savePost(post);
          streamController
              .add(VideoUpload(100, false, false, false, await url));
          break;
      }
    });
  } catch (e) {
    printLog(e.toString());
  }
}
