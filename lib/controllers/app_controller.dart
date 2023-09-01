// ignore_for_file: depend_on_referenced_packages
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trend_browser/helpers/bookmark_list.dart';
import 'package:trend_browser/helpers/read_write.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:trend_browser/models/download_model.dart';
import 'package:trend_browser/models/history_item_model.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:trend_browser/widgets/show_message.dart';

class AppController extends GetxController {
  InAppWebViewController? webViewController;
  PullToRefreshController? pullToRefreshController;
  final TextEditingController urlCon = TextEditingController();
  List bookmarks = [];
  RxBool isLoading = false.obs;
  RxString selected = "".obs;
  RxBool hideBottomSheet = false.obs;
  RxList history = [].obs;
  RxList downloadList = [].obs;

  getBookMarks() {
    try {
      isLoading(true);
      var data = read('localData');
      bookmarks = localData['bookmark_list']!;
      if(data != "") {
        for(Map<String, dynamic> item in data) {
          Map<String, String> dataMap = Map<String, String>.from(item.map(
            (key, value) => MapEntry<String, String>(key, value.toString()),
          ));
          bool bookmarkExists = bookmarks.any((data) => data['name'] == dataMap["name"]);
          if(!bookmarkExists) {
            bookmarks.add(dataMap);
          }
        }
      }
    } catch (e) {
      log(e.toString());
    } finally {
      isLoading(false);
    }
  }

  addBookMark(name, site) {
    try {
      isLoading(true);
      var data = {
        "name": name.toString(),
        "url": site.toString(),
        "img": ""
      };
      bookmarks.add(data);
      var localData = read('localData');
      if(localData == ""){
        write('localData', [data]);
      } else {
        localData.add(data);
        write('localData', localData);
      }
    } catch (e) {
      log(e.toString());
    } finally {
      isLoading(false);
    }
  }

  bool isURL(String string) {
    RegExp urlPattern = RegExp(
      r'^(https?://)?(www\.)?([a-zA-Z0-9\-]+)\.([a-zA-Z]{2,})(/[^\s]*)?$',
    );
    return urlPattern.hasMatch(string);
  }

  createHistory(String icon, name, url) {
    var historyItem = HistoryItemModel(url: url, title: name, icon: icon);
    history.add(historyItem);
    List historyJsonList = history.map((item) => item.toJson()).toList();
    write('history', historyJsonList);
  }

  getHistoryList() {
    // remove('history');
    var recent = read('history');
    if(recent != "") {
      history.clear();
      for(var item in recent) {
        history.add(HistoryItemModel.fromJson(item));
      }
    }
  }

  fileDownloadPermission(url) {
    return Get.dialog(
      AlertDialog(
        content: Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
          child: Text(
            'You are about to download ${url.suggestedFilename}. \n Are you sure?',
            textAlign: TextAlign.center
          ),
        ),
        contentPadding: const EdgeInsets.only(top: 8.0),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey
            ),
            onPressed: () => Get.back(),
            child: const Text('Cancel')
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red
            ),
            onPressed: () {
              Get.back();
              downloadFile(url);
            }, 
            child: const Text('Download')
          )
        ],
      ),
    );
  }

  downloadFile(url) async {
    await createDownloadLog(url);
    FileDownloader.downloadFile(
      url: url.url.toString(),
      name: url.suggestedFilename,
      onProgress: (String? fileName, double progress) {
        log('$fileName => $progress%');
      },
      onDownloadCompleted: (String path) {
        downloadCompleteShow(url);
      },
      onDownloadError: (String error) {
        downloadError(error, url);
      }
    );
  }

  createDownloadLog(url) {
    var downloadItem = DownloadModel(name: url.suggestedFilename, progress: 0.0, url: url.url.toString(), mimeType: url.mimeType, status: null, fileSize: url.contentLength);
    downloadList.add(downloadItem);
    List downloadJsonList = downloadList.map((item) => item.toJson()).toList();
    write('downloadList', downloadJsonList);
  }

  downloadCompleteShow(url) async {
    showMessage('Download Completed.');
    var lastIndex = downloadList.lastIndexWhere((element) => element.name == url.suggestedFilename);
    downloadList[lastIndex].status = "Completed";
    List downloadJsonList = downloadList.map((item) => item.toJson()).toList();
    write('downloadList', downloadJsonList);
  }

  downloadError(error, url) {
    showMessage(error);
    var lastIndex = downloadList.lastIndexWhere((element) => element.name == url.suggestedFilename);
    downloadList[lastIndex].status = "Failed";
    List downloadJsonList = downloadList.map((item) => item.toJson()).toList();
    write('downloadList', downloadJsonList);
  }

  getDownloadList() {
    try {
      isLoading(true);
      var data = read('downloadList');
      if(data != "") {
        downloadList.clear();
        for(var item in data) {
          downloadList.add(DownloadModel.fromJson(item));
        }
      }
    } catch (e) {
      log(e.toString());
    } finally {
      isLoading(false);
    }
  }

}