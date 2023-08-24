import 'dart:async';
import 'package:black_coffer/models/video_upload.dart';
import 'package:black_coffer/services/storage_repository.dart';
import 'package:cached_video_preview/cached_video_preview.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/user.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key, required this.location, required this.user});
  final String location;
  final MyUser user;
  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  String path = "";
  ValueNotifier<bool> isUploading = ValueNotifier(false);

  void getVideoFile() async {
    XFile? file = await ImagePicker().pickVideo(source: ImageSource.camera);
    setState(() {
      if (file != null) {
        path = file.path;
      } else {
        path = "";
      }
    });
  }

  final StreamController<VideoUploadState> _streamController =
      StreamController<VideoUploadState>();

  final key = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllerMap = {
    'title': TextEditingController(),
    'description': TextEditingController(),
    'category': TextEditingController(),
  };

  @override
  void initState() {
    super.initState();
    getVideoFile();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: key,
          child: Column(
            children: [
              TextFormField(
                controller: _controllerMap['title'],
                decoration: const InputDecoration(
                    label: Text("Title"), border: OutlineInputBorder()),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _controllerMap['description'],
                decoration: const InputDecoration(
                    label: Text("Description"), border: OutlineInputBorder()),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _controllerMap['category'],
                decoration: const InputDecoration(
                    label: Text("Category"), border: OutlineInputBorder()),
              ),
              const SizedBox(height: 24),
              Text("Location : ${widget.location}"),
              const SizedBox(height: 24),
              if (path.isNotEmpty)
                Column(
                  children: [
                    SizedBox(
                      height: 200,
                      child: CachedVideoPreviewWidget(
                        path: path,
                        type: SourceType.local,
                        fileImageBuilder: (context, bytes) =>
                            Image.memory(bytes),
                      ),
                    ),
                    ElevatedButton(
                        onPressed: () {
                          if (!isUploading.value) {
                            uploadVideoStream(
                              filePath: path,
                              uid: widget.user.uid,
                              title: _controllerMap['title']!.text,
                              description: _controllerMap['description']!.text,
                              category: _controllerMap['category']!.text,
                              location: widget.location,
                              streamController: _streamController,
                            );
                          }
                        },
                        child: Text(
                            isUploading.value ? "Uploading..." : "Upload")),
                    StreamBuilder<VideoUploadState>(
                        stream: _streamController.stream,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            var v = snapshot.data!;
                            if (v.isError || v.isSuccess) {
                              isUploading.value = false;
                            }
                            return Text(v.message);
                          }
                          return const SizedBox(height: 10);
                        })
                  ],
                )
            ],
          ),
        ),
      ),
    ));
  }
}