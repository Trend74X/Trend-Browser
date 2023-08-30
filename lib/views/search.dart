import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {

  // final TextEditingController _textEditingController = TextEditingController();
  final List<String> _suggestions = [
    'Apple',
    'Banana',
    'Orange',
    'Mango',
    'Grapes',
    'Pineapple',
    'Strawberry',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: urlBar(),
      ),
      body: const SizedBox(),
    );
  }

  urlBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Autocomplete(
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text == '') {
                return const Iterable<String>.empty();
              } else {
                  List<String> matches = <String>[];
                  matches.addAll(_suggestions);
                  matches.retainWhere((s){
                    return s.toLowerCase().contains(textEditingValue.text.toLowerCase());
                  });
                  // box.write('baseUrl', textEditingValue.text);
                  return matches;
              }
            },
            onSelected: (String selection) {
              // box.write('baseUrl', selection);
            },
            // fieldViewBuilder:(context, textEditingController, focusNode, onFieldSubmitted) {
            //   return TextField(
            //     controller: _textEditingController,
            //     focusNode: focusNode,
            //     onSubmitted: (value) {
            //       onFieldSubmitted();
            //       // Handle submission
            //     },
            //     decoration: const InputDecoration(
            //       hintText: 'Enter URL',
            //       border: InputBorder,
            //     ),
            //   );
            // },
          ),
        ],
      ),
    );
  }

}