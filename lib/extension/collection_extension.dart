extension ListExtension<T> on List<T> {
  T? firstWhereOrNull(bool Function(T element) predicate) {
    for (T element in this) {
      if (predicate(element)) return element;
    }
    return null;
  }
}

Iterable<E> mapIndexed<E, T>(
    Iterable<T> items, E Function(int index, T item) f) sync* {
  var index = 0;

  for (final item in items) {
    yield f(index, item);
    index = index + 1;
  }
}

extension IterableExtension on Iterable {
  num count<T>(num Function(T element) function) {
    num number = 0;
    forEach((element) {
      number += function.call(element);
    });
    return number;
  }
}
