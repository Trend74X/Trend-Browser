// ignore_for_file: unused_import, depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trend_browser/controllers/app_controller.dart';
import 'package:trend_browser/helpers/read_write.dart';
import 'package:trend_browser/widgets/display_image.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {

  final AppController _con = Get.put(AppController());

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Container(
        color: Colors.black87,
        height: MediaQuery.of(context).size.height - kToolbarHeight - kBottomNavigationBarHeight - MediaQuery.of(context).padding.top,
        width: MediaQuery.of(context).size.width,
        child: _con.history.isEmpty
          ? const Center(
            child: Text('No recent history')
          )
          : SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      _con.history.clear();
                      remove('history');
                    });
                  },
                  child: const SizedBox(
                    height: 35.0,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Clear browsing data...',
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
                  itemCount: _con.history.length,
                  shrinkWrap:true,
                  separatorBuilder: (context, index) => const Divider(color: Colors.white),
                  physics: const BouncingScrollPhysics(),
                  reverse: true,
                  itemBuilder: (context, index) {
                    return historyListTile(_con.history[index], index);
                  }
                ),
                const Divider(color: Colors.white)
              ],
            ),
          ),
      ),
    );
  }

  historyListTile(data, index) {
    return InkWell(
      onTap: () {
        if(mounted) {
          setState(() {
            _con.urlCon.text = data.url;
            _con.selected("view");
          });
        }
        write('storedUrl', data.url);
      },
      child: SizedBox(
        height: 52.0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              SizedBox(
                height: 30.0,
                width: 30.0,
                child: DisplayNetworkImage(
                  imageUrl: data.icon!,
                  height: 30.0,
                  width: 30.0,
                ),
              ),
              const SizedBox(width: 8.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: Text(
                      data.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: Text(
                      data.url,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ), 
              IconButton(
                onPressed: () {
                  setState(() {
                    _con.history.removeAt(index);
                    List historyJsonList = _con.history.map((item) => item.toJson()).toList();
                    write('history', historyJsonList);
                  });
                }, 
                icon: const Icon(
                  Icons.close,
                )
              )
            ],
          ),
        )
      ),
    );
  }
}