import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';

class VideoInfo {
  final String url;
  final String resolution;
  final int? sizeInBytes;

  VideoInfo({required this.url, required this.resolution, this.sizeInBytes});
}

class VideoScannerWebView extends StatefulWidget {
  final String inputUrl;
  const VideoScannerWebView({super.key, required this.inputUrl});

  @override
  State<VideoScannerWebView> createState() => _VideoScannerWebViewState();
}

class _VideoScannerWebViewState extends State<VideoScannerWebView> {
  late InAppWebViewController webViewController;
  final GlobalKey webViewKey = GlobalKey();
  String url = '';
  List<VideoInfo> videoInfoList = [];

  InAppWebViewSettings options = InAppWebViewSettings(
    useShouldOverrideUrlLoading: true,
    mediaPlaybackRequiresUserGesture: false,
    supportZoom: false,
    transparentBackground: true,
    disableContextMenu: true,
    useHybridComposition: true,
    builtInZoomControls: false,
    mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
    allowsInlineMediaPlayback: true,
  );

  void _extractVideos() async {
    String js = """
      (function() {
        var sources = document.querySelectorAll('video source');
        var videoData = [];

        sources.forEach(src => {
          var url = src.src || '';
          var label = src.getAttribute('label') || '';
          var qualityMatch = url.match(/(\\d{3,4}p)/);
          videoData.push({
            url: url,
            resolution: label || (qualityMatch ? qualityMatch[0] : 'unknown')
          });
        });

        return JSON.stringify(videoData);
      })();
    """;

    var result = await webViewController.evaluateJavascript(source: js);
    if (result != null && result is String && result.isNotEmpty) {
      List<dynamic> decoded = jsonDecode(result);
      List<VideoInfo> newVideos = [];

      for (var item in decoded) {
        String url = item['url'];
        String resolution = item['resolution'];

        int? size;
        try {
          final head = await http.head(Uri.parse(url));
          if (head.headers['content-length'] != null) {
            size = int.tryParse(head.headers['content-length']!);
          }
        } catch (_) {
          size = null;
        }

        newVideos.add(VideoInfo(
          url: url,
          resolution: resolution,
          sizeInBytes: size,
        ));
      }

      setState(() {
        videoInfoList = newVideos;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Video Scanner"),
        actions: [
          IconButton(
            icon: const Icon(Icons.scanner),
            onPressed: _extractVideos,
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: InAppWebView(
                key: webViewKey,
                initialUrlRequest: URLRequest(url: WebUri(widget.inputUrl)),
                initialSettings: options,
                onWebViewCreated: (controller) {
                  webViewController = controller;
                },
                onLoadStart: (controller, url) {
                  setState(() {
                    this.url = url.toString();
                  });
                },
                onLoadStop: (controller, url) async {
                  setState(() {
                    this.url = url.toString();
                  });
                },
                shouldOverrideUrlLoading: (controller, navigationAction) async {
                  var uri = navigationAction.request.url!;
                  if (!["http", "https", "file", "chrome", "data", "javascript", "about"].contains(uri.scheme)) {
                    return NavigationActionPolicy.CANCEL;
                  }
                  return NavigationActionPolicy.ALLOW;
                },
                onConsoleMessage: (controller, consoleMessage) {
                  debugPrint(consoleMessage.toString());
                },
              ),
            ),
            if (videoInfoList.isNotEmpty)
              Container(
                height: 200,
                color: Colors.grey[200],
                child: ListView.builder(
                  itemCount: videoInfoList.length,
                  itemBuilder: (_, index) {
                    final video = videoInfoList[index];
                    final sizeMB = (video.sizeInBytes ?? 0) / (1024 * 1024);
                    return ListTile(
                      title: Text(video.url, maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text(
                          'Resolution: ${video.resolution} • Size: ${video.sizeInBytes != null ? "${sizeMB.toStringAsFixed(2)} MB" : "Unknown"}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.download),
                        onPressed: () async => downloadVideoToMovies(context, video.url),
                      ),
                    );
                  },
                ),
              )
          ],
        ),
      ),
    );
  }

  Future<void> downloadVideoToMovies(BuildContext context, String videoUrl) async {
    final isGranted = await Permission.manageExternalStorage.request().isGranted;

    if (!isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Storage permission denied. Please allow it from settings.')),
      );
      return;
    }

    final fileName = p.basename(videoUrl);
    final moviesDir = Directory('/storage/emulated/0/Movies/MyVideoApp');

    if (!await moviesDir.exists()) {
      await moviesDir.create(recursive: true);
    }

    final filePath = p.join(moviesDir.path, fileName);
    final dio = Dio();

    try {
      await dio.download(
        videoUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = (received / total * 100).toStringAsFixed(0);
            debugPrint("Downloading... $progress%");
          }
        },
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Downloaded to Movies/MyVideoApp/$fileName')),
        );
      }
    } catch (e) {
      debugPrint("Download error: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Download failed')),
        );
      }
    }
  }

}