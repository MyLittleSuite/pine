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

import 'dart:async';
import 'dart:convert';

import 'package:analyzer/dart/element/element.dart';
import 'package:pine_annotations/pine_annotations.dart';
import 'package:pine_generator/src/generators/base_generator.dart';
import 'package:pine_generator/src/models/seeded.dart';
import 'package:source_gen/source_gen.dart';

class PineAnalyzeGenerator extends BaseGenerator {
  PineAnalyzeGenerator({
    required super.generatedExtension,
  });

  @override
  FutureOr<Object>? onGenerate(GeneratorContext context) {
    final annotations = context.library.annotatedWith(
      TypeChecker.fromRuntime(Seed),
    );

    final seededElements = <Seeded>[];
    for (final annotatedElement in annotations) {
      final element = annotatedElement.element;

      if (element is! ClassElement) {
        throw InvalidGenerationSourceError(
          '${element.displayName} is not a class and cannot be annotated with @Seed.',
          element: element,
          todo: 'Add @Seed to a class.',
        );
      }

      seededElements.add(
        Seeded.fromAnnotation(element, annotatedElement.annotation),
      );
    }

    return seededElements.isNotEmpty ? jsonEncode(seededElements) : null;
  }
}
