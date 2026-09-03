import 'package:restaurant_td/constant/constant.dart';
import 'package:restaurant_td/models/currency_model.dart';
import 'package:restaurant_td/utils/fire_store_utils.dart';
import 'package:restaurant_td/utils/notification_service.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constant/collection_name.dart';

class GlobalSettingController extends GetxController {
  @override
  void onInit() {
    notificationInit();
    getCurrentCurrency();

    // NOTE: zones/arrondissements are seeded by a SQL migration
    // (supabase/migrations/20260824_fix_zone_and_settings.sql), not from the
    // client. The old seedArrondissements() ran on every launch, required
    // write access to `zone`, and silently failed because the columns it wrote
    // (area/quartiers/latitude/longitude) did not exist.

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

    // Uses the shared single-flight loader so that screens which need the
    // settings (e.g. the subscription gate in SplashController) can await the
    // very same future instead of racing this background call.
    await FireStoreUtils.ensureSettingsLoaded();
  }

  NotificationService notificationService = NotificationService();

  void notificationInit() {
    // Local notifications only (Supabase backend, no Firebase Cloud Messaging).
    notificationService.initInfo();
  }
}
