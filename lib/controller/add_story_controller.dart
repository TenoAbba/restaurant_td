import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:restaurant_td/constant/constant.dart';
import 'package:restaurant_td/models/story_model.dart';
import 'package:restaurant_td/service/supabase_service.dart';
import 'package:restaurant_td/service/supabase_storage_service.dart';

class AddStoryController extends GetxController {
  RxBool isLoading = true.obs;

  Rx<StoryModel> storyModel = StoryModel().obs;
  final ImagePicker imagePicker = ImagePicker();

  RxList<dynamic> mediaFiles = <dynamic>[].obs;
  RxList<dynamic> thumbnailFile = <dynamic>[].obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getStory();
    super.onInit();
  }

  RxDouble videoDuration = 0.0.obs;

  getStory() async {
    await SupabaseService.getStory(Constant.userModel!.vendorID.toString())
        .then(
      (value) {
        if (value != null) {
          storyModel.value = StoryModel.fromJson(value);

          thumbnailFile.add(storyModel.value.videoThumbnail);
          for (var element in storyModel.value.videoUrl) {
            mediaFiles.add(element);
          }
        }
      },
    );
    await SupabaseService.getSettings('story').then((value) {
      if (value != null) {
        videoDuration.value = double.parse(value['videoDuration'].toString());
      }
    });
    isLoading.value = false;
  }
}
