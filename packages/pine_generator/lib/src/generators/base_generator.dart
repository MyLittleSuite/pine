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

import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:source_gen/source_gen.dart';

class GeneratorContext {
  final LibraryReader library;
  final BuildStep buildStep;

  GeneratorContext({
    required this.library,
    required this.buildStep,
  });
}

abstract class BaseGenerator extends Builder {
  final String generatedExtension;

  BaseGenerator({
    required this.generatedExtension,
  });

  @override
  Map<String, List<String>> get buildExtensions => {
        '.dart': [generatedExtension],
      };

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    if (!await buildStep.resolver.isLibrary(buildStep.inputId)) {
      return;
    }

    final generatedValue = await onGenerate(
      GeneratorContext(
        library: LibraryReader(await buildStep.inputLibrary),
        buildStep: buildStep,
      ),
    );

    if (generatedValue == null) {
      return;
    }

    final normalizedOutput = normalizeOutput(generatedValue);
    await buildStep.writeAsString(
      buildStep.inputId.changeExtension(generatedExtension),
      normalizedOutput,
    );
  }

  FutureOr<Object?> onGenerate(GeneratorContext context);

  String normalizeOutput(Object object) {
    if (object is Library) {
      final emitter = DartEmitter(useNullSafetySyntax: true);
      return DartFormatter()
          .format(object.accept(emitter).toString())
          .toString();
    }

    return object.toString();
  }
}
