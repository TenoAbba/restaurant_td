class StoryModel {
  String? videoThumbnail;
  List<dynamic> videoUrl = [];
  String? vendorID;
  DateTime? createdAt;

  StoryModel(
      {this.videoThumbnail,
      this.videoUrl = const [],
      this.vendorID,
      this.createdAt});

  StoryModel.fromJson(Map<String, dynamic> json) {
    videoThumbnail = json['videoThumbnail'] ?? '';
    videoUrl = json['videoUrl'] ?? [];
    vendorID = json['vendorID'] ?? '';
    createdAt = json['createdAt'] != null
        ? DateTime.tryParse(json['createdAt'].toString())
        : DateTime.now();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['videoThumbnail'] = videoThumbnail;
    data['videoUrl'] = videoUrl;
    data['vendorID'] = vendorID;
    data['createdAt'] = createdAt?.toIso8601String();
    return data;
  }
}
