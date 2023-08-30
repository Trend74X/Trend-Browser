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
      var data = read('localData');
      bookmarks = localData['homeList']!;
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

  bool isDownloadableLink(Uri url) {
    final List<String> validExtensions = ['.pdf', '.zip', '.jpg', '.png', '.doc'];
    final String linkExtension = url.path.split('.').last.toLowerCase();
    return validExtensions.contains(linkExtension);
  }

}