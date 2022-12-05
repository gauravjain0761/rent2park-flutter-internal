abstract class BaseCollection<T> {
  final List<T> items = <T>[];

  Future<void> insertAll(List<T> items);

  Future<void> insert(T item);

  Future<T?> get(String id);

  Future<void> clear();

  Future<bool> update(T item);
}
