import 'dart:async';
import 'package:black_coffer/models/video_upload.dart';
import 'package:black_coffer/services/storage_repository.dart';
import 'package:black_coffer/theme/colors.dart';
import 'package:cached_video_preview/cached_video_preview.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/user.dart';
import 'package:liquid_progress_indicator_v2/liquid_progress_indicator.dart';

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
    XFile? file = await ImagePicker().pickVideo(
        source: ImageSource.camera, maxDuration: const Duration(seconds: 15));
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
    videoPath.dispose();
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
                      if (value.isNotEmpty) {
                        _streamController.add(idleState);
                        return SizedBox(
                          height: 200,
                          child: CachedVideoPreviewWidget(
                            path: value,
                            type: SourceType.local,
                            fileImageBuilder: (context, bytes) =>
                                Image.memory(bytes),
                          ),
                        );
                      } else {
                        return Container(
                            height: 50,
                            width: double.infinity,
                            decoration: BoxDecoration(
                                border: Border.all(
                                    width: 2.0,
                                    color: getColors(context).primary),
                                borderRadius: BorderRadius.circular(8)),
                            child: TextButton(
                                onPressed: () => getVideoFile(),
                                child: const Text("Record video")));
                      }
                    },
                    child: Image.asset("assets/images/loading_failed.png")),
                const SizedBox(height: 30),
                SizedBox(
                  height: 50,
                  child: StreamBuilder<VideoUploadState>(
                      stream: _streamController.stream,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          var v = snapshot.data!;
                          if (v.isIdle) {
                            return Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 2.0,
                                      color: getColors(context).primary),
                                  borderRadius: BorderRadius.circular(8)),
                              child: TextButton(
                                  onPressed: () {
                                    if (key.currentState!.validate() &&
                                        videoPath.value.isNotEmpty) {
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
                                  child: const Text("Upload video",
                                      style: TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold))),
                            );
                          } else if (v.isUploading) {
                            return LiquidLinearProgressIndicator(
                              value: v.progress / 100,
                              valueColor: AlwaysStoppedAnimation(
                                  getColors(context).primary),
                              backgroundColor: getColors(context).background,
                              borderColor: getColors(context).primary,
                              borderWidth: 2.0,
                              borderRadius: 8.0,
                              center: Text(
                                v.message,
                                style: const TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold),
                              ),
                            );
                          } else {
                            return Container(
                                width: double.infinity,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: v.isSuccess
                                        ? getColors(context).primary
                                        : getColors(context).onPrimary,
                                    border: Border.all(
                                        width: 2.0,
                                        color: getColors(context).primary),
                                    borderRadius: BorderRadius.circular(8)),
                                child: Text(
                                  v.message,
                                  style: const TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold),
                                ));
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
