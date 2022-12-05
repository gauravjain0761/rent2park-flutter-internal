// import 'package:rent2car/collection/base_collection.dart';
// import 'package:rent2car/data/backend_responses.dart';
// import 'package:rent2car/extension/collection_extension.dart';

import 'package:rent2park/extension/collection_extension.dart';

import '../data/backend_responses.dart';
import 'base_collection.dart';

class VehicleCollection extends BaseCollection<Vehicle> {

  static final VehicleCollection instance = VehicleCollection._internal();

  VehicleCollection._internal();

  @override
  Future<void> clear() async => items.clear();

  @override
  Future<Vehicle?> get(String id) async => items.firstWhereOrNull((element) => element.id == int.parse(id));

  @override
  Future<void> insert(Vehicle item) async => items.insert(0, item);

  @override
  Future<void> insertAll(List<Vehicle> vehicles) async =>
      items.addAll(vehicles);

  @override
  Future<bool> update(Vehicle item) async {
    final Vehicle? lastVehicle = await get(item.id.toString());
    if (lastVehicle == null) return false;
    int itemRemovingIndex = items.indexOf(lastVehicle);
    if (itemRemovingIndex == -1) return false;
    items.removeAt(itemRemovingIndex);
    items.insert(itemRemovingIndex, item);
    return true;
  }

  Future<bool> remove(String id) async {
    final Vehicle? lastVehicle = await get(id);
    if (lastVehicle == null) return false;
    int itemRemovingIndex = items.indexOf(lastVehicle);
    if (itemRemovingIndex == -1) return false;
    items.removeAt(itemRemovingIndex);
    return true;
  }
}
