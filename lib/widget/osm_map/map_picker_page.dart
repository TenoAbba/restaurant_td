import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_td/themes/app_them_data.dart';
import 'package:restaurant_td/themes/round_button_fill.dart';
import 'package:restaurant_td/utils/dark_theme_provider.dart';
import 'package:restaurant_td/widget/osm_map/map_controller.dart';

class MapPickerPage extends StatelessWidget {
  final OSMMapController controller = Get.put(OSMMapController());
  final TextEditingController searchController = TextEditingController();

  MapPickerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeChange.getThem()
            ? AppThemeData.surfaceDark
            : AppThemeData.surface,
        centerTitle: false,
        titleSpacing: 0,
        title: Text(
          "PickUp Location".tr,
          textAlign: TextAlign.start,
          style: TextStyle(
            fontFamily: AppThemeData.medium,
            fontSize: 16,
            color: themeChange.getThem()
                ? AppThemeData.grey50
                : AppThemeData.grey900,
          ),
        ),
      ),
      body: Stack(
        children: [
          Obx(
            () => FlutterMap(
              mapController: controller.mapController,
              options: MapOptions(
                initialCenter: controller.pickedPlace.value?.coordinates ??
                    LatLng(20.5937, 78.9629), // Default India center
                initialZoom: 13,
                onTap: (tapPos, latlng) {
                  controller.addLatLngOnly(latlng);
                  controller.mapController
                      .move(latlng, controller.mapController.camera.zoom);
                },
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                  userAgentPackageName: 'com.tasolutions.restaurant_td',
                ),
                MarkerLayer(
                  markers: controller.pickedPlace.value != null
                      ? [
                          Marker(
                            point: controller.pickedPlace.value!.coordinates,
                            width: 40,
                            height: 40,
                            child: Icon(
                              Icons.location_pin,
                              size: 36,
                              color: AppThemeData.secondary300,
                            ),
                          ),
                        ]
                      : [],
                ),
              ],
            ),
          ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Column(
              children: [
                Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(8),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search location...'.tr,
                      contentPadding: EdgeInsets.all(12),
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      controller.searchPlace(value);
                    },
                  ),
                ),
                // Loading indicator
                Obx(() {
                  if (controller.isSearching.value) {
                    return Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: themeChange.getThem()
                            ? AppThemeData.grey900
                            : AppThemeData.grey50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppThemeData.secondary300),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Searching...'.tr,
                            style: TextStyle(
                              color: themeChange.getThem()
                                  ? AppThemeData.grey50
                                  : AppThemeData.grey900,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return SizedBox.shrink();
                }),
                Obx(() {
                  if (controller.searchResults.isEmpty)
                    return SizedBox.shrink();

                  return Material(
                    elevation: 8,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      margin: const EdgeInsets.only(top: 4),
                      constraints: BoxConstraints(
                        maxHeight: 300, // Limit height to prevent overflow
                      ),
                      decoration: BoxDecoration(
                        color: themeChange.getThem()
                            ? AppThemeData.grey900
                            : AppThemeData.grey50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: themeChange.getThem()
                              ? AppThemeData.grey700
                              : AppThemeData.grey300,
                          width: 1,
                        ),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: controller.searchResults.length,
                        separatorBuilder: (context, index) => Divider(
                          height: 1,
                          color: themeChange.getThem()
                              ? AppThemeData.grey800
                              : AppThemeData.grey200,
                        ),
                        itemBuilder: (context, index) {
                          final place = controller.searchResults[index];
                          return ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            leading: Icon(
                              Icons.location_on,
                              color: AppThemeData.secondary300,
                              size: 20,
                            ),
                            title: Text(
                              place['display_name'] ?? '',
                              style: TextStyle(
                                fontSize: 14,
                                color: themeChange.getThem()
                                    ? AppThemeData.grey50
                                    : AppThemeData.grey900,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () {
                              final lat = double.parse(place['lat']);
                              final lon = double.parse(place['lon']);
                              final pos = LatLng(lat, lon);
                              searchController.text = place['display_name'];
                              controller.selectSearchResult(place);
                              controller.mapController.move(pos, 15);
                            },
                          );
                        },
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Obx(() {
        return Container(
          padding: const EdgeInsets.all(16),
          color: themeChange.getThem()
              ? AppThemeData.grey900
              : AppThemeData.grey50,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                controller.pickedPlace.value != null
                    ? "Picked Location:".tr
                    : "No Location Picked".tr,
                style: TextStyle(
                  color: themeChange.getThem()
                      ? AppThemeData.secondary300
                      : AppThemeData.secondary300,
                  fontFamily: AppThemeData.semiBold,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              if (controller.pickedPlace.value != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Text(
                    "${controller.pickedPlace.value!.address}\n(${controller.pickedPlace.value!.coordinates.latitude.toStringAsFixed(5)}, ${controller.pickedPlace.value!.coordinates.longitude.toStringAsFixed(5)})",
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: RoundedButtonFill(
                      title: "Confirm Location".tr,
                      color: AppThemeData.secondary300,
                      textColor: AppThemeData.grey50,
                      height: 5,
                      onPress: () async {
                        final selected = controller.pickedPlace.value;
                        if (selected != null) {
                          Get.back(
                              result: selected); // ✅ Return the selected place
                          print("Selected location: $selected");
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.delete_forever, color: Colors.red),
                    onPressed: controller.clearAll,
                  )
                ],
              ),
            ],
          ),
        );
      }),
    );
  }
}
