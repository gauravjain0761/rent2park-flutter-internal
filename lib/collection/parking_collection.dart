
import 'package:rent2park/extension/collection_extension.dart';

import '../data/backend_responses.dart';
import 'base_collection.dart';

class ParkingSpaceCollection extends BaseCollection<ParkingSpaceDetail> {
  static final ParkingSpaceCollection instance =
      ParkingSpaceCollection._internal();

  ParkingSpaceCollection._internal();

  @override
  Future<void> clear() async => items.clear();

  @override
  Future<ParkingSpaceDetail?> get(String id) async =>
      items.firstWhereOrNull((element) => element.id == id);

  @override
  Future<void> insert(ParkingSpaceDetail item) async => items.insert(0, item);

  @override
  Future<void> insertAll(List<ParkingSpaceDetail> parkings) async =>
      items.addAll(parkings);

  @override
  Future<bool> update(ParkingSpaceDetail item) async => false;
}
