/*
 *
 *  * Copyright (c) 2024 MyLittleSuite
 *  *
 *  * Permission is hereby granted, free of charge, to any person
 *  * obtaining a copy of this software and associated documentation
 *  * files (the "Software"), to deal in the Software without
 *  * restriction, including without limitation the rights to use,
 *  * copy, modify, merge, publish, distribute, sublicense, and/or sell
 *  * copies of the Software, and to permit persons to whom the
 *  * Software is furnished to do so, subject to the following
 *  * conditions:
 *  *
 *  * The above copyright notice and this permission notice shall be
 *  * included in all copies or substantial portions of the Software.
 *  *
 *  * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 *  * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 *  * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 *  * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 *  * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 *  * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 *  * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 *  * OTHER DEALINGS IN THE SOFTWARE.
 *
 */

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:pine_generator/src/extensions/class_element.dart';
import 'package:pine_generator/src/extensions/dart_object.dart';
import 'package:pine_generator/src/misc/utilities.dart';
import 'package:pine_generator/src/models/constructor.dart';
import 'package:pine_generator/src/models/enums/injection_type.dart';
import 'package:pine_generator/src/models/enums/seeded_type.dart';
import 'package:pine_generator/src/models/interface.dart';
import 'package:source_gen/source_gen.dart';

class Seeded {
  final SeededType type;
  final bool singleton;
  final bool lazy;
  final Interface? parent;
  final String implementationName;
  final String humanReadable;
  final String import;
  final String onInitFunctionName;
  final Constructor? constructor;
  final int order;
  final InjectionType injection;

  const Seeded._({
    required this.type,
    required this.parent,
    required this.implementationName,
    required this.humanReadable,
    required this.singleton,
    required this.lazy,
    required this.injection,
    required this.import,
    required this.onInitFunctionName,
    this.constructor,
    this.order = 0,
  });

  String get constructorName => [implementationName, constructor?.name]
      .where((element) => element != null)
      .join('.');

  String get injectorClassName => [
        humanReadable,
        InjectionType.provider.widgetName,
      ].join();

  factory Seeded.fromAnnotation(
    ClassElement element,
    ConstantReader annotation,
  ) {
    final constructor = element.primaryConstructor;
    final constructorParams =
        annotation.peek('constructorParams')?.mapValue.map(
                  (key, value) => MapEntry(
                    key?.toStringValue(),
                    value?.toPrimitiveValue(),
                  ),
                ) ??
            {};

    return Seeded._(
      order: constructor?.parameters.length ?? 0,
      type: _guessSeededType(element.thisType),
      injection: _guessInjectionType(_guessSeededType(element.thisType)),
      parent: element.parent != null
          ? Interface.fromInterface(element.parent!)
          : null,
      implementationName: element.displayName,
      humanReadable: inHumanReadable(element.displayName),
      import: element.librarySource.uri.toString(),
      constructor: constructor != null
          ? Constructor.fromClassConstructor(constructor, constructorParams)
          : null,
      singleton: annotation.peek('singleton')?.boolValue ?? false,
      lazy: annotation.peek('lazy')?.boolValue ?? false,
      onInitFunctionName: [
        'on',
        element.displayName,
        'Init',
      ].join(),
    );
  }

  factory Seeded.fromJson(Map<String, dynamic> json) {
    return Seeded._(
      order: json['order'],
      type: SeededType.fromJsonValue(json['type']),
      injection: InjectionType.fromJsonValue(json['injection']),
      import: json['import'],
      parent:
          json['parent'] != null ? Interface.fromJson(json['parent']) : null,
      implementationName: json['implementationName'],
      humanReadable: json['humanReadable'],
      singleton: json['singleton'],
      lazy: json['lazy'],
      constructor: json['constructor'] != null
          ? Constructor.fromJson(json['constructor'])
          : null,
      onInitFunctionName: json['onInitFunctionName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order': order,
      'type': type.toJsonValue(),
      'injection': injection.toJsonValue(),
      'import': import,
      'parent': parent?.toJson(),
      'implementationName': implementationName,
      'humanReadable': humanReadable,
      'singleton': singleton,
      'lazy': lazy,
      'constructor': constructor?.toJson(),
      'onInitFunctionName': onInitFunctionName,
    };
  }

  static SeededType _guessSeededType(DartType type) {
    final typeName = type.getDisplayString().toLowerCase();

    if (typeName.contains('bloc')) {
      return SeededType.bloc;
    } else if (typeName.contains('repository')) {
      return SeededType.repository;
    } else if (typeName.contains('mapper')) {
      return SeededType.mapper;
    }

    return SeededType.generic;
  }

  static InjectionType _guessInjectionType(SeededType type) => switch (type) {
        SeededType.bloc => InjectionType.blocProvider,
        SeededType.repository => InjectionType.repositoryProvider,
        _ => InjectionType.provider,
      };
}
