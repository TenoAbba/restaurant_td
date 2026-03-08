class ZoneModel {
  // area stores polygon points as {latitude: x, longitude: y} maps
  List<Map<String, double>>? area;
  bool? publish;
  double? latitude;
  String? name;
  String? id;
  double? longitude;
  List<dynamic>? quartiers;

  ZoneModel(
      {this.area,
      this.publish,
      this.latitude,
      this.name,
      this.id,
      this.longitude,
      this.quartiers});

  ZoneModel.fromJson(Map<String, dynamic> json) {
    if (json['area'] != null) {
      area = <Map<String, double>>[];
      (json['area'] as List).forEach((v) {
        if (v is Map) {
          area!.add({
            'latitude': double.tryParse(v['latitude'].toString()) ?? 0.0,
            'longitude': double.tryParse(v['longitude'].toString()) ?? 0.0,
          });
        }
      });
    }
    publish = json['publish'];
    latitude = double.tryParse(json['latitude'].toString());
    name = json['name'];
    id = json['id'];
    longitude = double.tryParse(json['longitude'].toString());
    quartiers = json['quartiers'] ?? [];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (area != null) {
      data['area'] = area!.map((v) => v).toList();
    }
    data['publish'] = publish;
    data['latitude'] = latitude;
    data['name'] = name;
    data['id'] = id;
    data['longitude'] = longitude;
    data['quartiers'] = quartiers;
    return data;
  }
}
