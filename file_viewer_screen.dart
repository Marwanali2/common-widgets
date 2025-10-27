import 'package:flutter/material.dart';
import 'package:raw7any/core/theme/text_styles.dart';
import 'package:video_player/video_player.dart';
import 'package:webview_flutter/webview_flutter.dart';

class FileViewerScreen extends StatefulWidget {
  final String url;
  final String? title;
  const FileViewerScreen({super.key, required this.url, this.title});

  @override
  State<FileViewerScreen> createState() => _FileViewerScreenState();
}

class _FileViewerScreenState extends State<FileViewerScreen> {
  late final String ext;
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    ext = widget.url.split('.').last.toLowerCase();

    if (['mp4', 'mov', 'avi'].contains(ext)) {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.url))
        ..initialize().then((_) => setState(() {}));
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (['pdf'].contains(ext)) {
      final googleDocsUrl =
          'https://docs.google.com/gview?embedded=true&url=${widget.url}';
      content = WebViewWidget(
        controller: WebViewController()
          ..loadRequest(Uri.parse(googleDocsUrl))
          ..setJavaScriptMode(JavaScriptMode.unrestricted),
      );
    } else if (['jpg', 'jpeg', 'png'].contains(ext)) {
      content = Center(child: Image.network(widget.url));
    } else if (['mp4', 'mov', 'avi'].contains(ext)) {
      if (_videoController?.value.isInitialized ?? false) {
        content = AspectRatio(
          aspectRatio: _videoController!.value.aspectRatio,
          child: VideoPlayer(_videoController!),
        );
      } else {
        content = const Center(child: CircularProgressIndicator());
      }
    } else if (['doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx'].contains(ext)) {
      final googleDocsUrl =
          'https://docs.google.com/gview?embedded=true&url=${widget.url}';
      content = WebViewWidget(
        controller: WebViewController()
          ..loadRequest(Uri.parse(googleDocsUrl))
          ..setJavaScriptMode(JavaScriptMode.unrestricted),
      );
    } else {
      content = WebViewWidget(
        controller: WebViewController()
          ..loadRequest(Uri.parse(widget.url))
          ..setJavaScriptMode(JavaScriptMode.unrestricted),
      );
    }

    return Scaffold(
      appBar: AppBar(
          title: Text(
        widget.title ?? '',
        style: TextStyles.blackBold16,
      )),
      body: content,
      floatingActionButton: _videoController != null
          ? FloatingActionButton(
              onPressed: () {
                setState(() {
                  _videoController!.value.isPlaying
                      ? _videoController!.pause()
                      : _videoController!.play();
                });
              },
              child: Icon(_videoController!.value.isPlaying
                  ? Icons.pause
                  : Icons.play_arrow),
            )
          : null,
    );
  }
}
