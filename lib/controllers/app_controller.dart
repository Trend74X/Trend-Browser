// ignore_for_file: depend_on_referenced_packages
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trend_browser/helpers/constants.dart';
import 'package:trend_browser/helpers/read_write.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:trend_browser/models/history_item_model.dart';

class AppController extends GetxController {
  InAppWebViewController? webViewController;
  PullToRefreshController? pullToRefreshController;
  final TextEditingController urlCon = TextEditingController();
  List bookmarks = [];
  RxBool isLoading = false.obs;
  RxString selected = "".obs;
  RxBool hideBottomSheet = false.obs;
  RxList history = [].obs;

  getBookMarks() {
    try {
      isLoading(true);
      if(read('firstTime') == null|| read('firstTime') == '') {
        write('firstTime', false);
        bookmarks = localData['homeList']!;
        write('localData', bookmarks);
      } else {
        var data = read('localData');
        bookmarks = data;
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
      bookmarks.add({
        "name": name.toString(),
        "url": site.toString(),
        "img": ""
      });
      write('localData', bookmarks);
    } catch (e) {
      log(e.toString());
    } finally {
      isLoading(false);
    }
  }

  bool isURL(String string) {
    Uri? uri = Uri.tryParse(string);
    return uri != null && uri.hasScheme && uri.hasAuthority;
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

  bool isDownloadableLink(Uri url) {
    final List<String> validExtensions = ['.pdf', '.zip', '.jpg', '.png', '.doc'];
    final String linkExtension = url.path.split('.').last.toLowerCase();
    return validExtensions.contains(linkExtension);
  }

}