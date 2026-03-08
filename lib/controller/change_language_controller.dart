import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';
import 'package:restaurant_td/constant/constant.dart';
import 'package:restaurant_td/models/language_model.dart';
import 'package:restaurant_td/utils/fire_store_utils.dart';
import 'package:restaurant_td/utils/preferences.dart';

import '../constant/collection_name.dart';

class ChangeLanguageController extends GetxController {
  Rx<LanguageModel> selectedLanguage = LanguageModel().obs;
  RxList<LanguageModel> languageList = <LanguageModel>[].obs;
  RxBool isLoading = true.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getLanguage();

    super.onInit();
  }

  getLanguage() async {
    final row = await Supabase.instance.client
        .from(CollectionName.settings)
        .select('data')
        .eq('key', 'languages')
        .maybeSingle();
    if (row != null) {
      final event = row['data'] as Map<String, dynamic>? ?? {};
      if (event.isNotEmpty) {
        List languageListTemp = event["list"] ?? [];
        for (var element in languageListTemp) {
          LanguageModel languageModel = LanguageModel.fromJson(element);
          languageList.add(languageModel);
        }

        if (Preferences.getString(Preferences.languageCodeKey)
            .toString()
            .isNotEmpty) {
          LanguageModel pref = Constant.getLanguage();
          for (var element in languageList) {
            if (element.slug == pref.slug) {
              selectedLanguage.value = element;
            }
          }
        }
      }
    }

    isLoading.value = false;
  }
}
