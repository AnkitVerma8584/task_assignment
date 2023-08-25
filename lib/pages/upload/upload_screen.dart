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
  ValueNotifier<String> videoPath = ValueNotifier("");
  final StreamController<VideoUploadState> _streamController =
      StreamController<VideoUploadState>();

  void getVideoFile() async {
    XFile? file = await ImagePicker().pickVideo(source: ImageSource.camera);
    setState(() {
      if (file != null) {
        videoPath.value = file.path;
      } else {
        videoPath.value = "";
      }
    });
  }

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
    _controllerMap['location'] = TextEditingController(text: widget.location);
  }

  @override
  void dispose() {
    super.dispose();
    for (var element in _controllerMap.entries) {
      element.value.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(title: const Text("Upload post")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: key,
            child: Column(
              children: [
                FormInput(
                  controller: _controllerMap['title']!,
                  label: "Title",
                  maxLine: 1,
                ),
                const SizedBox(height: 24),
                FormInput(
                  controller: _controllerMap['description']!,
                  label: "Description",
                  maxLine: 3,
                ),
                const SizedBox(height: 24),
                FormInput(
                  controller: _controllerMap['category']!,
                  label: "Category",
                  maxLine: 1,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _controllerMap['location'],
                  readOnly: true,
                  decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.location_pin),
                      label: Text("Location"),
                      border: OutlineInputBorder()),
                ),
                const SizedBox(height: 24),
                ValueListenableBuilder<String>(
                    valueListenable: videoPath,
                    builder: (context, value, widget) {
                      _streamController.add(idleState);
                      return SizedBox(
                        height: 200,
                        child: value.isNotEmpty
                            ? CachedVideoPreviewWidget(
                                path: value,
                                type: SourceType.local,
                                fileImageBuilder: (context, bytes) =>
                                    Image.memory(bytes),
                              )
                            : widget,
                      );
                    },
                    child: Image.asset("assets/images/loading_failed.png")),
                const SizedBox(height: 30),
                SizedBox(
                  height: 100,
                  child: StreamBuilder<VideoUploadState>(
                      stream: _streamController.stream,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          var v = snapshot.data!;
                          if (v.isIdle) {
                            return ElevatedButton(
                                onPressed: () {
                                  if (key.currentState!.validate()) {
                                    uploadVideoStream(
                                      filePath: videoPath.value,
                                      uid: widget.user.uid,
                                      title: _controllerMap['title']!.text,
                                      description:
                                          _controllerMap['description']!.text,
                                      category:
                                          _controllerMap['category']!.text,
                                      location: widget.location,
                                      streamController: _streamController,
                                    );
                                  }
                                },
                                child: const Text("Upload video"));
                          } else {
                            return Text(v.message);
                          }
                        }
                        return const SizedBox(height: 50);
                      }),
                )
              ],
            ),
          ),
        ),
      ),
    ));
  }
}

class FormInput extends StatelessWidget {
  const FormInput(
      {super.key,
      required TextEditingController controller,
      required this.label,
      required this.maxLine})
      : _controller = controller;

  final TextEditingController _controller;
  final String label;
  final int maxLine;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
        controller: _controller,
        maxLines: maxLine,
        decoration: InputDecoration(
            label: Text(label), border: const OutlineInputBorder()),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Required*";
          }
          return null;
        });
  }
}
