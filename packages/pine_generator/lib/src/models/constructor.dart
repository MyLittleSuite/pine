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
import 'package:pine_generator/src/models/injectable_field.dart';

class Constructor {
  final String? name;
  final bool isConst;
  final bool isFactory;
  final List<InjectableField> fields;

  Constructor._({
    required this.name,
    required this.fields,
    this.isConst = false,
    this.isFactory = false,
  });

  factory Constructor.fromClassConstructor(
    ConstructorElement element,
    Map<String?, Object?> injectValues,
  ) {
    return Constructor._(
      name: element.name.isNotEmpty ? element.name : null,
      isConst: element.isConst,
      isFactory: element.isFactory,
      fields: element.parameters
          .map(
            (element) => InjectableField.fromParameter(element, injectValues),
          )
          .toList(growable: false),
    );
  }

  factory Constructor.fromJson(Map<String, dynamic> json) => Constructor._(
        name: json['name'] as String?,
        fields: (json['fields'] as List)
            .map((e) => InjectableField.fromJson(e as Map<String, dynamic>))
            .toList(),
        isConst: json['isConst'] as bool,
        isFactory: json['isFactory'] as bool,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'fields': fields.map((e) => e.toJson()).toList(growable: false),
        'isConst': isConst,
        'isFactory': isFactory,
      };
}
