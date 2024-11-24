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

import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:glob/glob.dart';
import 'package:pine_annotations/pine_annotations.dart';
import 'package:pine_generator/src/generators/base_generator.dart';
import 'package:pine_generator/src/models/seeded.dart';
import 'package:pine_generator/src/processors/injector_class_processor.dart';
import 'package:pine_generator/src/processors/processor.dart';
import 'package:pine_generator/src/processors/seed_container_processor.dart';
import 'package:source_gen/source_gen.dart';

class PineDIGenerator extends BaseGenerator {
  final String findExtension;
  final Processor<List<Expression>> typedefsProcessor;
  final Processor<List<Directive>> importsProcessor;
  final Processor<Class> seedContainerProcessor;
  final Processor<Class> injectorProcessor;

  PineDIGenerator({
    required super.generatedExtension,
    required this.findExtension,
    required this.typedefsProcessor,
    required this.importsProcessor,
    required this.seedContainerProcessor,
    required this.injectorProcessor,
  });

  @override
  FutureOr<Object?> onGenerate(GeneratorContext context) async {
    final seedContainerElements = context.library.annotatedWith(
      TypeChecker.fromRuntime(SeedContainer),
      throwOnUnresolved: false,
    );
    if (seedContainerElements.isEmpty) {
      return null;
    }

    final seededElements = await _readSeededElements(context.buildStep);
    if (seededElements == null) {
      return null;
    }

    final processorContext = ProcessorContext(
      plants: seededElements,
    );

    return Library(
      (b) => b
        ..directives.addAll(
          importsProcessor.process(processorContext),
        )
        ..body.addAll(
          [
            ...typedefsProcessor.process(processorContext),
            seedContainerProcessor.process(SeedContainerProcessorContext(
              containerName: 'PineSeeded',
              plants: seededElements,
            )),
            ...seededElements.where((element) => element.singleton).map(
                  (element) => injectorProcessor.process(
                    InjectorClassProcessorContext(
                      currentPlant: element,
                      plants: seededElements,
                    ),
                  ),
                ),
          ],
        ),
    );
  }

  Future<List<Seeded>?> _readSeededElements(BuildStep buildStep) async {
    final seededElements = <Seeded>[];
    await for (final asset in buildStep.findAssets(Glob('**$findExtension'))) {
      final jsonResource = jsonDecode(await buildStep.readAsString(asset));

      final seeded = switch (jsonResource) {
        Map<String, dynamic>() => [Seeded.fromJson(jsonResource)],
        List<dynamic>() => jsonResource.map((element) {
            if (element is! Map<String, dynamic>) {
              throw UnimplementedError(
                'Unsupported json type: ${element.runtimeType}',
              );
            }

            return Seeded.fromJson(element);
          }),
        _ => throw UnimplementedError(
            'Unsupported json type: ${jsonResource.runtimeType}',
          ),
      };

      seededElements.addAll(seeded);
    }

    seededElements.sort((first, second) => first.order.compareTo(second.order));
    return seededElements;
  }
}
