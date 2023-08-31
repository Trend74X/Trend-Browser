// ignore_for_file: unused_import, depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trend_browser/controllers/app_controller.dart';
import 'package:trend_browser/helpers/read_write.dart';
import 'package:trend_browser/widgets/display_image.dart';
import 'package:mimecon/mimecon.dart';

class DownloadPage extends StatefulWidget {
  const DownloadPage({super.key});

  @override
  State<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {

  final AppController _con = Get.put(AppController());

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Container(
        color: Colors.black87,
        height: MediaQuery.of(context).size.height - kToolbarHeight - kBottomNavigationBarHeight - MediaQuery.of(context).padding.top,
        width: MediaQuery.of(context).size.width,
        child: _con.downloadList.isEmpty
          ? const Center(
            child: Text('No recent downloads')
          )
          : SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      _con.downloadList.clear();
                      remove('downloadList');
                    });
                  },
                  child: const SizedBox(
                    height: 35.0,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Clear all download records',
                        style: TextStyle(
                          color: Colors.red
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  ),
                ),
                const Divider(color: Colors.white),
                ListView.separated(
                  itemCount: _con.downloadList.length,
                  shrinkWrap:true,
                  separatorBuilder: (context, index) => const Divider(color: Colors.white),
                  physics: const BouncingScrollPhysics(),
                  reverse: true,
                  itemBuilder: (context, index) {
                    return downloadListTile(_con.downloadList[index], index);
                  }
                ),
                const Divider(color: Colors.white)
              ],
            ),
          ),
      ),
    );
  }

  downloadListTile(data, index) {
    return SizedBox(
      height: 52.0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            SizedBox(
              height: 30.0,
              width: 30.0,
              child:  Mimecon(
                mimetype: data.mimeType,
                color: Colors.red,
                size: 25,
                isOutlined: true,
              ),
            ),
            const SizedBox(width: 8.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: Text(
                    data.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: data.status == 'Failed'
                              ? Colors.grey
                              : Colors.white
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.2,
                      child: Text(
                        '${(data.fileSize / 1000000).toStringAsFixed(2)} MB',
                        style: TextStyle(
                          color: data.status == 'Failed'
                                ? Colors.grey
                                : Colors.white
                        ),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: Text(
                        data.status == null || data.status == 'Downloading' 
                          ? 'Downloading' 
                          : data.status == 'Failed'
                            ? 'Failed'
                            : data.url,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        softWrap: true,
                        style: TextStyle(
                          color: data.status == 'Failed'
                                ? Colors.grey
                                : Colors.white
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ), 
            IconButton(
              onPressed: () {
                setState(() {
                  _con.downloadList.removeAt(index);
                  List downloadJsonList = _con.downloadList.map((item) => item.toJson()).toList();
                  write('downloadList', downloadJsonList);
                });
              }, 
              icon: const Icon(
                Icons.close,
              )
            )
          ],
        ),
      )
    );
  }

}