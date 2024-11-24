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
import 'package:pine_generator/src/misc/expressions.dart';
import 'package:pine_generator/src/models/seeded.dart';
import 'package:pine_generator/src/processors/processor.dart';

class InjectorClassProcessorContext extends ProcessorContext {
  final Seeded currentPlant;

  InjectorClassProcessorContext({
    required this.currentPlant,
    required super.plants,
  });
}

class InjectorClassProcessor extends Processor<Class> {
  @override
  Class process(ProcessorContext context) {
    if (context is! InjectorClassProcessorContext) {
      throw ArgumentError(
        'InjectorClassProcessorContext is required to process InjectorClassProcessor',
      );
    }

    final plant = context.currentPlant;
    return Class((b) => b
      ..docs.add('/// The provider for ${plant.implementationName}')
      ..name = plant.injectorClassName
      ..extend = refer(
        plant.injection.widgetNameOf(context.currentPlant.implementationName),
      )
      ..constructors.add(
        Constructor(
          (b) => b
            ..optionalParameters.addAll(
              [
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
                    ..toSuper = true,
                ),
                Parameter(
                  (b) => b
                    ..name = context.onInitRef
                    ..named = true
                    ..type = refer(
                      context.onInitTypeOfRef(
                        plant.implementationName,
                        nullable: true,
                      ),
                    ),
                ),
              ],
            )
            ..initializers.add(
              Block(
                (b) {
                  b.statements.add(Code('super(create:'));
                  b.statements.add(createContextClosure(
                    context.contextRef,
                    _expressionsForCreate(context, plant),
                    trailingComma: true,
                  ).code);
                  b.statements.add(Code('lazy: ${plant.lazy},'));
                  b.statements.add(Code(')'));
                },
              ),
            ),
        ),
      ));
  }

  List<Expression> _expressionsForCreate(
    InjectorClassProcessorContext context,
    Seeded plant,
  ) {
    final resultKey = 'result';
    final resultRef = refer(resultKey);

    return [
      declareFinal(resultKey).assign(
        _fillDependency(context, plant, firstLevel: true),
      ),
      refer(context.onInitRef).nullSafeProperty('call').call(
        [refer(context.contextRef), resultRef],
      ),
      resultRef.returned,
    ];
  }

  Expression _fillDependency(
    InjectorClassProcessorContext context,
    Seeded? plant, {
    bool firstLevel = false,
    Object? defaultValue,
  }) {
    if (defaultValue != null) {
      return literal(defaultValue);
    }

    if (plant == null) {
      return literal(null);
    }

    if (!firstLevel && plant.singleton) {
      return readFromContext(context.contextRef);
    }

    final positionalFields =
        plant.constructor!.fields.where((field) => field.positional).map(
              (field) => _fillDependency(
                context,
                _findRelatedPlant(context, [field.type]),
                defaultValue: field.value,
              ),
            );

    final namedFields = plant.constructor!.fields
        .where((field) => field.named)
        .toList(growable: false)
        .asMap()
        .map(
          (_, field) => MapEntry(
            field.name,
            _fillDependency(
              context,
              _findRelatedPlant(
                context,
                [field.type],
              ),
              defaultValue: field.value,
            ),
          ),
        );

    final isConstructorConst = plant.constructor?.isConst == true &&
        positionalFields.isEmpty &&
        namedFields.isEmpty;
    final constructorConst = isConstructorConst ? 'const ' : '';
    return refer('$constructorConst${plant.constructorName}').newInstance(
      positionalFields,
      namedFields,
    );
  }

  Seeded? _findRelatedPlant(
    InjectorClassProcessorContext context,
    List<String?> classNames,
  ) =>
      classNames
          .map((name) => context.namedPlants[name])
          .where((element) => element != null)
          .firstOrNull;
}
