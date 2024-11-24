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

import 'package:code_builder/code_builder.dart';
import 'package:pine_generator/src/models/enums/injection_type.dart';
import 'package:pine_generator/src/processors/processor.dart';

class InjectMethodProcessorContext extends ProcessorContext {
  final String referenceName;
  final InjectionType injectionType;

  InjectMethodProcessorContext({
    required this.referenceName,
    required this.injectionType,
    required super.plants,
  });
}

class InjectMethodProcessor extends Processor<Method> {
  @override
  Method process(ProcessorContext context) {
    if (context is! InjectMethodProcessorContext) {
      throw ArgumentError(
        'InjectMethodProcessorContext is required to process InjectMethodProcessor',
      );
    }

    return Method(
      (b) => b
        ..name = context.referenceName
        ..lambda = true
        ..type = MethodType.getter
        ..returns = refer('List<${context.injectionType.widgetName}>')
        ..body = literal(
          context.plants
              .where((plant) => plant.singleton)
              .where((plant) => plant.constructor != null)
              .map(
                (plant) => CodeExpression(
                  Block.of([
                    refer(plant.injectorClassName).call(
                      [],
                      {
                        context.onInitRef: refer(plant.onInitFunctionName),
                      },
                    ).code,
                  ]),
                ),
              )
              .toList(growable: false),
        ).code,
    );
  }
}
