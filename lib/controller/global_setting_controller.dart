import 'package:restaurant_td/constant/constant.dart';
import 'package:restaurant_td/models/currency_model.dart';
import 'package:restaurant_td/models/user_model.dart';
import 'package:restaurant_td/utils/fire_store_utils.dart';
import 'package:restaurant_td/utils/notification_service.dart';
import 'package:get/get.dart';
import '../constant/collection_name.dart';

class GlobalSettingController extends GetxController {
  @override
  void onInit() {
    notificationInit();
    getCurrentCurrency();
    seedArrondissements(); // Call this once then comment out

    super.onInit();
  }

  getCurrentCurrency() async {
    Supabase.instance.client
        .from(CollectionName.currencies)
        .stream(primaryKey: ['id'])
        .eq('isActive', true)
        .listen((rows) {
      if (rows.isNotEmpty) {
        Constant.currencyModel = CurrencyModel.fromJson(rows.first);
      } else {
        Constant.currencyModel = CurrencyModel(
            id: "",
            code: "USD",
            decimalDigits: 2,
            enable: true,
            name: "US Dollar",
            symbol: "\$",
            symbolAtRight: false);
      }
    });
    await FireStoreUtils().getSettings();
  }

  NotificationService notificationService = NotificationService();

  void notificationInit() {
    notificationService.initInfo().then((value) async {
      String token = await NotificationService.getToken();
      if (Supabase.instance.client.auth.currentUser != null) {
        await FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid())
            .then((value) {
          if (value != null) {
            UserModel model = value;
            model.fcmToken = token;
            FireStoreUtils.updateUser(model);
          }
        });
      }
    });
  }

  Future<void> seedArrondissements() async {
    // Basic N'Djamena Bounding Box (Approximate)
    List<Map<String,double>> nDjamenaArea = [
      {'latitude':12.1645,'longitude':14.9904},
      {'latitude':12.1645,'longitude':15.1324},
      {'latitude':12.0628,'longitude':15.1324},
      {'latitude':12.0628,'longitude':14.9904},
    ];

    List<String> firstArrondissementQuartiers = [
      "Farcha",
      "Milezi",
      "Madjorio",
      "Guilmeye",
      "Djougoulier",
      "Karkandjeri",
      "Amsinéné",
      "Guinébor",
      "N'Djamena-Koudou",
      "Massil Abcoma",
      "Zaraf",
      "Allaya",
      "Ardeb-Timan",
      "Antona"
    ];

    List<Map<String, dynamic>> arrondissements = [
      {"name": "1er Arrondissement", "quartiers": firstArrondissementQuartiers},
      {"name": "2e Arrondissement", "quartiers": <String>[]},
      {"name": "3e Arrondissement", "quartiers": <String>[]},
      {"name": "4e Arrondissement", "quartiers": <String>[]},
      {"name": "5e Arrondissement", "quartiers": <String>[]},
      {"name": "6e Arrondissement", "quartiers": <String>[]},
      {"name": "7e Arrondissement", "quartiers": <String>[]},
      {"name": "8e Arrondissement", "quartiers": <String>[]},
      {"name": "9e Arrondissement", "quartiers": <String>[]},
      {"name": "10e Arrondissement", "quartiers": <String>[]},
    ];

    final _supaDb = Supabase.instance.client;

    for (var arr in arrondissements) {
      // Check if exists to avoid overwrite
      final query = await _supaDb.from('zone').select('id').eq('name', arr['name']);
      if (query.isEmpty) {
        final id = const Uuid().v4();
        await _supaDb.from('zone').upsert({'id':id,'name':arr['name'],'publish':true,'area':nDjamenaArea,'quartiers':arr['quartiers'],'latitude':12.1131,'longitude':15.0491});
        print("Seeded ${arr['name']}");
      }
    }
  }
}
