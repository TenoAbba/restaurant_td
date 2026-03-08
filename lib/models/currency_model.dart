class CurrencyModel {
  DateTime? createdAt;
  String? symbol;
  String? code;
  bool? enable;
  bool? symbolAtRight;
  String? name;
  int? decimalDigits;
  String? id;
  DateTime? updatedAt;

  CurrencyModel(
      {this.createdAt,
      this.symbol,
      this.code,
      this.enable,
      this.symbolAtRight,
      this.name,
      this.decimalDigits,
      this.id,
      this.updatedAt});

  CurrencyModel.fromJson(Map<String, dynamic> json) {
    createdAt = json['createdAt'] != null
        ? DateTime.tryParse(json['createdAt'].toString())
        : null;
    symbol = json['symbol'];
    code = json['code'];
    enable = json['enable'];
    symbolAtRight = json['symbolAtRight'];
    name = json['name'];
    decimalDigits = json['decimal_degits'] != null
        ? (json['decimal_degits'] is num
            ? (json['decimal_degits'] as num).toInt()
            : int.tryParse(json['decimal_degits'].toString()) ?? 0)
        : 0;
    id = json['id'];
    updatedAt = json['updatedAt'] != null
        ? DateTime.tryParse(json['updatedAt'].toString())
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['createdAt'] = createdAt?.toIso8601String();
    data['symbol'] = symbol;
    data['code'] = code;
    data['enable'] = enable;
    data['symbolAtRight'] = symbolAtRight;
    data['name'] = name;
    data['decimal_degits'] = decimalDigits;
    data['id'] = id;
    data['updatedAt'] = updatedAt?.toIso8601String();
    return data;
  }
}
