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

class InjectableField {
  final String name;
  final String type;
  final bool named;
  final String? import;
  final Object? value;

  InjectableField._({
    required this.name,
    required this.type,
    required this.named,
    this.import,
    this.value,
  });

  bool get positional => !named;

  factory InjectableField.fromParameter(
    ParameterElement element,
    Map<String?, Object?> injectValues,
  ) {
    return InjectableField._(
      name: element.name,
      type: element.type.getDisplayString(),
      named: element.isNamed,
      import: element.type.element?.librarySource?.uri.toString(),
      value: injectValues[element.name],
    );
  }

  factory InjectableField.fromJson(Map<String, dynamic> json) =>
      InjectableField._(
        name: json['name'] as String,
        type: json['type'] as String,
        named: json['named'] as bool,
        import: json['import'] as String?,
        value: json['value'],
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'type': type,
        'named': named,
        'import': import,
        'value': value,
      };
}
