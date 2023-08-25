class VideoUploadState {
  final String message;
  final String videoPath;
  final bool isError, isSuccess, isIdle, isUploading;
  VideoUploadState({
    required this.message,
    required this.videoPath,
    required this.isIdle,
    required this.isError,
    required this.isSuccess,
    required this.isUploading,
  });
}

var idleState = VideoUploadState(
  message: "No video selected",
  videoPath: "",
  isIdle: true,
  isError: false,
  isSuccess: false,
  isUploading: false,
);

uploadState(String message, String videoPath) => VideoUploadState(
      message: message,
      videoPath: videoPath,
      isIdle: false,
      isError: false,
      isSuccess: false,
      isUploading: true,
    );

successState(String videoPath) => VideoUploadState(
      message: "Post uploaded successfully",
      videoPath: videoPath,
      isIdle: false,
      isError: false,
      isSuccess: true,
      isUploading: false,
    );

errorState(String videoPath, String error) => VideoUploadState(
      message: error,
      videoPath: videoPath,
      isIdle: false,
      isError: true,
      isSuccess: false,
      isUploading: false,
    );
