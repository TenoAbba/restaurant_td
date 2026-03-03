class PermissionModel {
  String? title;
  bool? isAdd;
  bool? isView;
  bool? isDelete;

  PermissionModel({
    required this.title,
    this.isAdd,
    this.isView,
    this.isDelete,
  });

  factory PermissionModel.fromJson(Map<String, dynamic> json) {
    return PermissionModel(
      title: json['title'] ?? '',
      isAdd: json['isAdd'],
      isView: json['isView'],
      isDelete: json['isDelete'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      if (isAdd != null) 'isAdd': isAdd,
      if (isView != null) 'isView': isView,
      if (isDelete != null) 'isDelete': isDelete,
    };
  }
}
