import 'package:flutter/services.dart';

/// A custom extension of the `TextInputType` class, which allows adding
/// a custom name property. This can be used to define new types of input fields.
class ExtendedTextInputType extends TextInputType {
  /// Constructor that requires a `name` parameter.
  /// The constructor initializes the base class with default `numberWithOptions` values.
  const ExtendedTextInputType({
    required this.name,
  }) : super.numberWithOptions(
          signed: null, // No specific signed option defined.
          decimal: null, // No specific decimal option defined.
        );

  /// A string that holds the name of the custom input type.
  final String name;

  /// Converts the current instance into a JSON representation.
  /// This can be useful when you need to serialize the input type.
  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name, // Adds the 'name' property to the JSON.
    };
  }

  /// Compares two `ExtendedTextInputType` objects.
  /// Returns true if they have the same name, otherwise false.
  @override
  bool operator ==(Object other) {
    return other is ExtendedTextInputType && other.name == name;
  }

  /// Generates a hash code based on the `name` property.
  @override
  int get hashCode => name.hashCode;
}
