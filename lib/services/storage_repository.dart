import 'dart:async';
import 'package:black_coffer/models/video_upload.dart';
import 'package:black_coffer/services/firestore_repository.dart';
import 'package:black_coffer/util/common.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:video_compress/video_compress.dart';

import '../models/post.dart';

final storageRef = FirebaseStorage.instance.ref();

void uploadVideoStream({
  required String filePath,
  required String uid,
  required String title,
  required String description,
  required String category,
  required String location,
  required StreamController<VideoUploadState> streamController,
}) async {
  final child = "POST:${getTimeStampExtention()}";
  streamController.add(VideoUploadState("Compressing video...", false, false));
  final video = await VideoCompress.compressVideo(filePath);
  final videoRef = storageRef.child(uid).child(child);
  streamController.add(VideoUploadState("Starting upload...", false, false));

  try {
    final uploadTask = videoRef.putFile(
        video!.file!, SettableMetadata(contentType: "video/mp4"));

    uploadTask.snapshotEvents.listen((TaskSnapshot taskSnapshot) async {
      switch (taskSnapshot.state) {
        case TaskState.running:
          final progress =
              100.0 * (taskSnapshot.bytesTransferred / taskSnapshot.totalBytes);

          streamController.add(VideoUploadState(
              "Uploading ${progress.toStringAsFixed(2)} %", false, false));
          break;
        case TaskState.paused:
          streamController
              .add(VideoUploadState("Upload paused !", true, false));
          break;
        case TaskState.canceled:
          streamController
              .add(VideoUploadState("Upload cancelled !", true, false));
          break;
        case TaskState.error:
          streamController
              .add(VideoUploadState("Some error occurred.", true, false));
          break;
        case TaskState.success:
          streamController
              .add(VideoUploadState("Just a moment...", false, false));
          var url = await taskSnapshot.ref.getDownloadURL();
          streamController.add(VideoUploadState("Finalizing...", false, false));
          Post post = Post(
            userId: uid,
            videoTitle: title,
            videoDescription: description,
            videoCategory: category,
            videoUrl: url,
            videoLocation: location,
          );
          await savePost(post, child);
          streamController
              .add(VideoUploadState("Post uploaded successfully", false, true));
          break;
      }
    });
  } catch (e) {
    streamController.add(VideoUploadState(e.toString(), true, false));
  }
}
