import 'dart:convert';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:restaurant_td/utils/utils.dart';
import 'package:restaurant_td/widget/osm_map/place_model.dart';

class OSMMapController extends GetxController {
  final mapController = MapController();
  // Store only one picked place instead of multiple
  var pickedPlace = Rxn<PlaceModel>(); // Use Rxn to hold a nullable value
  var searchResults = [].obs;
  var isSearching = false.obs; // Add loading state

  Future<void> searchPlace(String query) async {
    if (query.length < 3) {
      searchResults.clear();
      isSearching.value = false;
      return;
    }

    isSearching.value = true;

    try {
      final url = Uri.parse(
          'https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1&limit=10');

      final response = await http.get(url, headers: {
        'User-Agent': 'RestaurantTD/1.0 (ta.solutions.td@gmail.com)',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        searchResults.value = data;
      } else {
        searchResults.clear();
      }
    } catch (e) {
      searchResults.clear();
    } finally {
      isSearching.value = false;
    }
  }

  void selectSearchResult(Map<String, dynamic> place) {
    final lat = double.parse(place['lat']);
    final lon = double.parse(place['lon']);
    final address = place['display_name'];

    // Store only the selected place
    pickedPlace.value = PlaceModel(
      coordinates: LatLng(lat, lon),
      address: address,
    );

    // Delay clearing to allow tap gesture to complete
    Future.delayed(Duration(milliseconds: 100), () {
      searchResults.clear();
    });
  }

  void addLatLngOnly(LatLng coords) async {
    final address = await _getAddressFromLatLng(coords);
    pickedPlace.value = PlaceModel(coordinates: coords, address: address);
  }

  Future<String> _getAddressFromLatLng(LatLng coords) async {
    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?lat=${coords.latitude}&lon=${coords.longitude}&format=json');

    final response = await http.get(url, headers: {
      'User-Agent': 'RestaurantTD/1.0 (ta.solutions.td@gmail.com)',
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['display_name'] ?? 'Unknown location';
    } else {
      return 'Unknown location';
    }
  }

  void clearAll() {
    pickedPlace.value = null; // Clear the selected place
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    getCurrentLocation();
  }

  getCurrentLocation() async {
    Position? location = await Utils.getCurrentLocation();
    LatLng latlng =
        LatLng(location?.latitude ?? 0.0, location?.longitude ?? 0.0);
    addLatLngOnly(
        LatLng(location?.latitude ?? 0.0, location?.longitude ?? 0.0));
    mapController.move(latlng, mapController.camera.zoom);
  }
}
