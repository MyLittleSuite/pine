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
import 'package:pine_generator/src/models/enums/seeded_type.dart';
import 'package:pine_generator/src/processors/inject_method_processor.dart';
import 'package:pine_generator/src/processors/processor.dart';

class SeedContainerProcessorContext extends ProcessorContext {
  final String containerName;

  SeedContainerProcessorContext({
    required this.containerName,
    required super.plants,
  });
}

class SeedContainerProcessor extends Processor<Class> {
  final Processor<Method> diContainerMethodProcessor;
  final Processor<Method> injectMethodProcessor;

  SeedContainerProcessor({
    required this.diContainerMethodProcessor,
    required this.injectMethodProcessor,
  });

  @override
  Class process(ProcessorContext context) {
    if (context is! SeedContainerProcessorContext) {
      throw ArgumentError(
        'SeedContainerProcessorContext is required to process SeedContainerProcessor',
      );
    }

    final singletonPlants = context.plants.where((plant) => plant.singleton);
    return Class(
      (b) => b
        ..name = context.containerName
        ..extend = refer('StatelessWidget')
        ..fields.addAll([
          Field(
            (b) => b
              ..name = context.childWidgetRef
              ..modifier = FieldModifier.final$
              ..type = refer('Widget'),
          ),
          ...singletonPlants.map(
            (plant) => Field(
              (b) => b
                ..name = plant.onInitFunctionName
                ..modifier = FieldModifier.final$
                ..type = refer(
                  context.onInitTypeOfRef(
                    plant.implementationName,
                    nullable: true,
                  ),
                ),
            ),
          ),
        ])
        ..constructors.add(
          Constructor(
            (b) => b
              ..constant = true
              ..optionalParameters.addAll([
                Parameter(
                  (b) => b
                    ..name = context.keyRef
                    ..named = true
                    ..toSuper = true,
                ),
                Parameter(
                  (b) => b
                    ..name = context.childWidgetRef
                    ..named = true
                    ..toThis = true
                    ..required = true,
                ),
                ...singletonPlants.map(
                  (plant) => Parameter(
                    (b) => b
                      ..name = plant.onInitFunctionName
                      ..named = true
                      ..toThis = true,
                  ),
                ),
              ]),
          ),
        )
        ..methods.addAll(
          [
            diContainerMethodProcessor.process(context),
            ...[
              (
                context.blocsRef,
                InjectionType.blocProvider,
                context.plantsOfType(SeededType.bloc),
              ),
              (
                context.repositoriesRef,
                InjectionType.repositoryProvider,
                context.plantsOfType(SeededType.repository),
              ),
              (
                context.mappersRef,
                InjectionType.provider,
                context.plantsOfType(SeededType.mapper),
              ),
              (
                context.providersRef,
                InjectionType.provider,
                context.plantsOfType(SeededType.generic),
              ),
            ].map(
              (e) => injectMethodProcessor.process(
                InjectMethodProcessorContext(
                  referenceName: e.$1,
                  injectionType: e.$2,
                  plants: e.$3,
                ),
              ),
            ),
          ],
        ),
    );
  }
}
