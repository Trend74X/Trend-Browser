// ignore_for_file: depend_on_referenced_packages, unrelated_type_equality_checks
import 'package:flutter/material.dart';
import 'package:trend_browser/controllers/app_controller.dart';
import 'package:trend_browser/helpers/read_write.dart';
import 'package:trend_browser/views/tabs/download_page.dart';
import 'package:trend_browser/views/tabs/tab_home.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:trend_browser/views/tabs/tabs_history.dart';
import 'package:trend_browser/views/website_view.dart';
import 'package:get/get.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AppController _con = Get.put(AppController());
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: Obx(() => 
            _con.selected.value == 'history'
              ? const Text('History')
              : _con.selected.value == 'download'
                ? const Text('Downloads')
                : Row(
                  children: [
                    Expanded(
                      flex: 7,
                      child: urlField()
                    ),
                    Expanded(
                      child: downloadIcon()
                    )
                  ],
                )
          )
        ),
        body: Obx(() =>
          _con.selected.value == ""
            ? const TabHome()
            : _con.selected.value == "history"
              ? const History()
              : _con.selected.value == "download"
                ? const DownloadPage()
                : const WebsiteView()
        ),
        bottomSheet: bottomContainer(),
      ),
    );
  }

  urlField() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: TextFormField(
        controller: _con.urlCon,
        keyboardType: TextInputType.url,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          hintText: 'Enter URL',
          filled: true,
          fillColor: Colors.white,        
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          suffixIcon: _con.selected.value == 'view'
            ? IconButton(
                onPressed: () => _con.webViewController!.reload(),
                icon: const Icon(
                  Icons.refresh,
                  color: Colors.grey,
                ),
              )
            : null,
        ),
        onFieldSubmitted: (value) {
          if(_con.isURL(value)) {
            if(!value.contains('http') || !value.contains('https')) {
              _con.urlCon.text = 'https://$value';
            } else {
              _con.urlCon.text = value;
            }
          } else {
            _con.urlCon.text = "https://www.google.com/search?q=$value";
          }
          write('storedUrl', _con.urlCon.text);
          if(_con.selected.value != 'view') {
            _con.selected("view");
          } else {
            _con.webViewController!.loadUrl(urlRequest: URLRequest(url: Uri.parse(_con.urlCon.text)));
          }
        }
      ),
    );
  }

  bottomContainer() {
    return Container(
      color: Colors.black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          //Back
          IconButton(
            onPressed: () {
              if (_con.webViewController != null && _con.selected.value == "view") {
                _con.webViewController!.goBack();
              }
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: _con.webViewController != null && _con.selected.value == "view" ? Colors.white : Colors.grey,
            )
          ),
          //Forward
          IconButton(
            onPressed: () {
              if (_con.webViewController != null && _con.selected.value == "view") {
                _con.webViewController!.goForward();
              }
            },
            icon: Icon(
              Icons.arrow_forward_ios,
              color: _con.webViewController != null && _con.selected.value == "view" ? Colors.white : Colors.grey,
            )
          ),
          //Home
          IconButton(
            onPressed: () => setState(() => _con.selected("") ),
            icon: const Icon(
              Icons.home,
              color: Colors.white,
            )
          ),
          //Tabs
          IconButton(
            onPressed: () => setState(() => _con.selected("view") ),
            icon: const Icon(
              Icons.tab,
              color: Colors.white,
            )
          ),
          //More
          IconButton(
            onPressed: () => setState(() => _con.selected("history") ),
            icon: const Icon(
              Icons.history,
              color: Colors.white,
            )
          ),
        ],
      ),
    );
  }

  downloadIcon() {
    return IconButton(
      onPressed: () {
        _con.selected('download');
      }, 
      icon: const Icon(
        Icons.download,
        size: 35.0,
      )
    );
  }

}