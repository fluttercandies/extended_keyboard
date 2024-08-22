/// Class representing the height of the keyboard and its active state.
class KeyboardHeight {
  KeyboardHeight({
    required this.height,
    required this.isActive,
  });
  final double height;
  bool isActive = false;

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KeyboardHeight &&
          runtimeType == other.runtimeType &&
          height == other.height;

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode => height.hashCode;
}
