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

import 'package:build/build.dart';
import 'package:pine_generator/pine_generator.dart';
import 'package:pine_generator/src/processors/di_container_method_processor.dart';
import 'package:pine_generator/src/processors/imports_processor.dart';
import 'package:pine_generator/src/processors/inject_method_processor.dart';
import 'package:pine_generator/src/processors/injector_class_processor.dart';
import 'package:pine_generator/src/processors/seed_container_processor.dart';
import 'package:pine_generator/src/processors/typedefs_processor.dart';

/// Entry point for the pine generator, DI phase
Builder pineDI(BuilderOptions options) => PineDIGenerator(
      findExtension: '.pine.json',
      generatedExtension: '.di.pine.dart',
      typedefsProcessor: TypedefsProcessor(),
      importsProcessor: ImportsProcessor(),
      injectorProcessor: InjectorClassProcessor(),
      seedContainerProcessor: SeedContainerProcessor(
        diContainerMethodProcessor: DIContainerMethodProcessor(),
        injectMethodProcessor: InjectMethodProcessor(),
      ),
    );
