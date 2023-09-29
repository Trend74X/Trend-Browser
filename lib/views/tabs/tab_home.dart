// ignore_for_file: depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:trend_browser/controllers/app_controller.dart';
import 'package:trend_browser/helpers/read_write.dart';
import 'package:trend_browser/widgets/custom_button.dart';
import 'package:trend_browser/widgets/custom_textfield.dart';
import 'package:trend_browser/widgets/display_image.dart';
import 'package:get/get.dart';

class TabHome extends StatefulWidget {
  const TabHome({super.key});

  @override
  State<TabHome> createState() => TabHomeState();
}

class TabHomeState extends State<TabHome> {

  final AppController _con = Get.put(AppController());
  final siteNameCon = TextEditingController();
  final siteUrlCon = TextEditingController();
  bool removeBookmark = false;

  @override
  void initState() {
    _con.getBookMarks();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: GestureDetector(
        onTap: () => setState(() => removeBookmark = false ),
        child: Scaffold(
          backgroundColor: Colors.black87,
          body: Padding(
            padding: const EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 58.0),
            child:  Obx(() =>
              _con.isLoading.value == true
                ? const Center(
                  child: CircularProgressIndicator(),
                )
                : GridView.count(
                  crossAxisCount: 3,
                  mainAxisSpacing: 16.0,
                  children: List.generate(
                    _con.bookmarks.length + 1, 
                    (index) {
                      if(index < _con.bookmarks.length) {
                        var data = _con.bookmarks[index];
                        return InkWell(
                          onTap: () {
                            write('storedUrl', data['url']);
                            setState(() {
                              _con.urlCon.text = data['url'];
                              _con.selected("view");
                            });
                          },
                          onLongPress: () => setState(() => removeBookmark = true),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Stack(
                                children: [
                                  DisplayNetworkImage(
                                    imageUrl: data['img']!,
                                    height: 90.0,
                                    width: 100.0,
                                  ),
                                  showDeleteIcon(index)
                                ],
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                data['name']!,
                                style: const TextStyle(
                                  fontSize: 16.0,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1
                              ),
                            ],
                          ),
                        );
                      } else {
                        return InkWell(
                          onTap: () => showAddBookmark(),
                          child: Column(
                            children: const [
                              Icon(
                                Icons.add,
                                size: 90.0,
                              ),
                              SizedBox(height: 8.0),
                              Text(
                                'Add New',
                                style: TextStyle(
                                  fontSize: 16.0
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    }
                  ) 
                ),
            )
          )
        ),
      ),
    );
  }

  showAddBookmark() {
    return Get.defaultDialog(
      title: 'Add Bookmark',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          customTextField(siteNameCon, 'Site Name', TextInputType.name ),
          const SizedBox(height: 8.0),
          customTextField(siteUrlCon, 'Site Url', TextInputType.url ),
          const SizedBox(height: 8.0),
          customButton(
            'Add',
            () async {
              if(siteNameCon.text != '' && siteUrlCon.text != '') {
                await _con.addBookMark(siteNameCon.text, siteUrlCon.text);
                siteNameCon.clear();
                siteUrlCon.clear();
                setState(() { });
                Get.back();
              }
            }
          )
        ],
      )
    );
  }

  showDeleteIcon(index) {
    return Visibility(
      visible: removeBookmark && index > 8,
      child: Positioned(
        top: 0.0,
        right: 0.0,
        child: Container(
          height: 25.0,
          width: 25.0,
          decoration: const BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.all(Radius.circular(25.0))
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            color: Colors.white,
            icon: const Icon(Icons.close),
            onPressed: () {
              setState(() {
                _con.bookmarks.removeAt(index);
              });
              write('localData', _con.bookmarks);
            },
          )
        )
      ),
    );
  }

}