// ignore_for_file: depend_on_referenced_packages
import 'dart:io';
import 'dart:developer';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:trend_browser/controllers/app_controller.dart';
import 'package:trend_browser/helpers/read_write.dart';

class WebsiteView extends StatefulWidget {
  const WebsiteView({Key? key}) : super(key: key);

  @override
  State<WebsiteView> createState() => _WebsiteViewState();
}

class _WebsiteViewState extends State<WebsiteView> {
  String url = "";
  double progress = 0;
  final GlobalKey webViewKey = GlobalKey();
  
  final AppController _con = Get.put(AppController());

  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
    crossPlatform: InAppWebViewOptions(
      useShouldOverrideUrlLoading: true,
      mediaPlaybackRequiresUserGesture: false,
      supportZoom: false,
      transparentBackground: true,
      javaScriptEnabled: true,
      useOnDownloadStart: true,
      userAgent: 'Mozilla/5.0 (Linux; Android 11; Pixel 5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.181 Mobile Safari/537.36',
    ),
    android: AndroidInAppWebViewOptions(
      useHybridComposition: true,
      builtInZoomControls: false,
      mixedContentMode: AndroidMixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
      useWideViewPort: false,
      forceDark: AndroidForceDark.FORCE_DARK_AUTO,
    ),
    ios: IOSInAppWebViewOptions(
      allowsInlineMediaPlayback: true,
    )
  );

  @override
  void initState() {
    super.initState();
    _con.pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(
        color: Colors.red,
      ),
      onRefresh: () async {
        if (Platform.isAndroid) {
          _con.webViewController?.reload();
        } else if (Platform.isIOS) {
          _con.webViewController?.loadUrl(
            urlRequest: URLRequest(url: await _con.webViewController?.getUrl())
          );
        }
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    String initialUrl = read('storedUrl') == "" || read('storedUrl') == "about:blank" ? "https://www.google.com" : read('storedUrl');
    return WillPopScope(
      onWillPop: () async {
        if (_con.webViewController != null) {
          _con.webViewController!.goBack();
        }
        return false;
      },
      child: Scaffold(
        body: SafeArea(
          child: SizedBox(
            height: MediaQuery.of(context).size.height - kToolbarHeight - 80,
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Stack(
                    children: [
                      InAppWebView(
                        key: webViewKey,
                        initialUrlRequest: URLRequest(url: Uri.parse(initialUrl)),
                        initialOptions: options,
                        pullToRefreshController: _con.pullToRefreshController,
                        onWebViewCreated: (controller) {
                          _con.webViewController = controller;
                        },
                        onLoadStart: (controller, url) async {
                          setState(() {
                            this.url = url.toString();
                            _con.urlCon.text = url.toString();
                            write('storedUrl', url.toString());
                          });
                          var uri = url.toString();
                          var icon = await controller.getFavicons();
                          var name = await controller.getTitle();
                          _con.createHistory(icon[0].url.toString(), name, uri);
                        },
                        androidOnPermissionRequest: (controller, origin, resources) async {
                          return PermissionRequestResponse(
                            resources: resources,
                            action: PermissionRequestResponseAction.GRANT
                          );
                        },
                        shouldOverrideUrlLoading: (controller, navigationAction) async {
                          // var uri = navigationAction.request.url!.toString();
                          // if (![ "http", "https", "file", "chrome",
                          //   "data", "javascript", "about"].contains(uri.scheme)) {
                          //   if (await canLaunchUrl(Uri.parse(url))) {
                          //     // Launch the App
                          //     await launchUrl(
                          //       Uri.parse(url),
                          //     );
                          //     // and cancel the request
                          //     return NavigationActionPolicy.CANCEL;
                          //   }
                          // }
                          return NavigationActionPolicy.ALLOW;
                        },
                        onLoadStop: (controller, url) async {
                          _con.pullToRefreshController!.endRefreshing();
                          setState(() {
                            this.url = url.toString();
                            _con.urlCon.text = url.toString();
                            write('storedUrl', url.toString());
                          });
                        },
                        onLoadError: (controller, url, code, message) {
                          _con.pullToRefreshController!.endRefreshing();
                        },
                        onProgressChanged: (controller, progress) {
                          if (progress == 100) {
                            _con.pullToRefreshController!.endRefreshing();
                          }
                          setState(() {
                            this.progress = progress / 100;
                          });
                        },
                        onUpdateVisitedHistory: (controller, url, androidIsReload) {
                          setState(() {
                            this.url = url.toString();
                          });
                        },
                        onConsoleMessage: (controller, consoleMessage) {
                          debugPrint(consoleMessage.toString());
                        },
                        onLoadResource: (controller, resource) {
                          final url = resource.url;
                          log(url.toString());
                        },
                        onDownloadStartRequest: (controller, url) async {
                          if(_con.selected.value == "view") {
                            _con.fileDownloadPermission(url);
                          }
                        },

                        // onEnterFullscreen: (controller) {
                        //   SystemChrome.setPreferredOrientations([
                        //     DeviceOrientation.landscapeLeft,
                        //   ]);
                        //   // AutoOrientation.landscapeRightMode();
                        // },
                        // onExitFullscreen: (controller) {
                        //   setState(() {
                        //     SystemChrome.setPreferredOrientations(
                        //       [DeviceOrientation.portraitUp],
                        //     );
                        //   });
                        // },
                      ),
                      progress < 1.0
                        ? LinearProgressIndicator(value: progress, color: Colors.red)
                        : Container(),
                    ],
                  ),
                ),
              ]
            ),
          ),
        )
      )
    );
  }

}