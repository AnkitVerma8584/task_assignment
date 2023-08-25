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
  streamController.add(uploadState("Compressing video...", 0.0, filePath));
  final video = await VideoCompress.compressVideo(filePath);
  final videoRef = storageRef.child(uid).child(child);
  streamController.add(uploadState("Starting upload...", 0.0, filePath));

  try {
    final uploadTask = videoRef.putFile(
        video!.file!, SettableMetadata(contentType: "video/mp4"));

    uploadTask.snapshotEvents.listen((TaskSnapshot taskSnapshot) async {
      switch (taskSnapshot.state) {
        case TaskState.running:
          final progress =
              100.0 * (taskSnapshot.bytesTransferred / taskSnapshot.totalBytes);
          streamController.add(uploadState(
              "Uploading ${progress.toStringAsFixed(2)} %",
              progress,
              filePath));
          break;
        case TaskState.paused:
          streamController.add(errorState("Upload paused.", filePath));
          break;
        case TaskState.canceled:
          streamController.add(errorState("Upload cancelled.", filePath));
          break;
        case TaskState.error:
          streamController.add(errorState("Some error occurred.", filePath));
          break;
        case TaskState.success:
          streamController.add(uploadState("Just a moment...", 100, filePath));
          var url = await taskSnapshot.ref.getDownloadURL();
          streamController.add(uploadState("Finalizing...", 100, filePath));
          Post post = Post(
            userId: uid,
            videoTitle: title,
            videoDescription: description,
            videoCategory: category,
            videoUrl: url,
            videoLocation: location,
          );
          await savePost(post, child);
          streamController.add(successState(filePath));
          break;
      }
    });
  } catch (e) {
    streamController.add(errorState(e.toString(), filePath));
  }
}
