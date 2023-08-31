class DownloadModel {
  String? name;
  double? progress;
  String? url;
  String? mimeType;
  String? status;
  int? fileSize;

  DownloadModel({required this.name, required this.progress, required this.url, required this.mimeType, this.status, required this.fileSize});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'progress': progress,
      'url': url,
      'mimeType': mimeType,
      'status': status ?? 'Downloading',
      'fileSize': fileSize
    };
  }

  factory DownloadModel.fromJson(Map<String, dynamic> json) {
    return DownloadModel(
      name: json['name'],
      progress: json['progress'],
      url: json['url'],
      mimeType: json['mimeType'],
      status: json['status'] ?? 'Downloading',
      fileSize: json['fileSize']
    );
  }
}