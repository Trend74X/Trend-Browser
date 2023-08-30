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

  @override
  void initState() {
    _con.getBookMarks();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 48.0),
        child:  Obx(() =>
          _con.isLoading.value == true
            ? const Center(
              child: CircularProgressIndicator(),
            )
            : GridView.count(
              crossAxisCount: 3,
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
                      child: Stack(
                        children: [
                          Column(
                            children: [
                              DisplayNetworkImage(
                                imageUrl: data['img']!,
                                height: 100.0,
                                width: 100.0,
                              ),
                              Text(data['name']!),
                            ],
                          ),
                          Positioned(
                            top: 0.0,
                            right: 0.0,
                            child: IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                // Handle close button press here
                              },
                            ),
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
                            size: 100.0,
                          ),
                          Text('Add New'),
                        ],
                      ),
                    );
                  }
                }
              ) 
            ),
        )
      )
    );
  }

  showAddBookmark() {
    return Get.defaultDialog(
      title: 'Add Bookmark',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          customTextField(siteNameCon),
          const SizedBox(height: 8.0),
          customTextField(siteUrlCon),
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

}