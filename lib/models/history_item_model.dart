class HistoryItemModel {
  final String url;
  final String? icon;
  final String? title;

  HistoryItemModel({required this.url, required this.icon, required this.title});

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'icon': icon,
      'title': title,
    };
  }

  factory HistoryItemModel.fromJson(Map<String, dynamic> json) {
    return HistoryItemModel(
      url: json['url'],
      icon: json['icon'],
      title: json['title'],
    );
  }
}