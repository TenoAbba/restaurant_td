class CashbackModel {
  bool? allCustomer;
  bool? allPayment;
  double? cashbackAmount;
  String? cashbackType;
  List<String>? customerIds;
  DateTime? endDate;
  String? id;
  bool? isEnabled;
  double? maximumDiscount;
  double? minimumPurchaseAmount;
  List<String>? paymentMethods;
  int? redeemLimit;
  DateTime? startDate;
  String? title;
  double? cashbackValue;

  CashbackModel({
    this.allCustomer,
    this.allPayment,
    this.cashbackAmount,
    this.cashbackValue,
    this.cashbackType,
    this.customerIds,
    this.endDate,
    this.id,
    this.isEnabled,
    this.maximumDiscount,
    this.minimumPurchaseAmount,
    this.paymentMethods,
    this.redeemLimit,
    this.startDate,
    this.title,
  });

  factory CashbackModel.fromJson(Map<String, dynamic> json) {
    return CashbackModel(
      allCustomer: json['allCustomer'],
      allPayment: json['allPayment'],
      cashbackAmount: (json['cashbackAmount'] != null)
          ? double.tryParse(json['cashbackAmount'].toString())
          : null,
      cashbackValue: (json['cashbackValue'] != null)
          ? double.tryParse(json['cashbackValue'].toString())
          : null,
      cashbackType: json['cashbackType'] ?? '',
      customerIds: json['customerIds'] != null
          ? List<String>.from(json['customerIds'])
          : null,
      endDate: json['endDate'] != null
          ? DateTime.tryParse(json['endDate'].toString())
          : null,
      id: json['id'],
      isEnabled: json['isEnabled'],
      maximumDiscount: (json['maximumDiscount'] != null)
          ? double.tryParse(json['maximumDiscount'].toString())
          : null,
      minimumPurchaseAmount: (json['minumumPurchaseAmount'] != null)
          ? double.tryParse(json['minumumPurchaseAmount'].toString())
          : null,
      paymentMethods: json['paymentMethods'] != null
          ? List<String>.from(json['paymentMethods'])
          : null,
      redeemLimit: int.parse("${json['redeemLimit'] ?? 0}"),
      startDate: json['startDate'] != null
          ? DateTime.tryParse(json['startDate'].toString())
          : null,
      title: json['title'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'allCustomer': allCustomer,
      'allPayment': allPayment,
      'cashbackAmount': cashbackAmount,
      if (cashbackValue != null) 'cashbackValue': cashbackValue,
      'cashbackType': cashbackType,
      'customerIds': customerIds,
      'endDate': endDate,
      'id': id,
      'isEnabled': isEnabled,
      'maximumDiscount': maximumDiscount,
      'minumumPurchaseAmount': minimumPurchaseAmount,
      'paymentMethods': paymentMethods,
      'redeemLimit': redeemLimit,
      'startDate': startDate,
      'title': title,
    };
  }
}
