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

import 'package:pine_generator/src/models/enums/seeded_type.dart';
import 'package:pine_generator/src/models/seeded.dart';

class ProcessorContext {
  final Iterable<Seeded> plants;

  final String contextRef = 'context';
  final String childWidgetRef = 'child';
  final String keyRef = 'key';
  final String blocsRef = '_blocs';
  final String repositoriesRef = '_repositories';
  final String mappersRef = '_mappers';
  final String providersRef = '_providers';
  final String onInitRef = 'onInit';

  const ProcessorContext({
    required this.plants,
  });

  Map<String, Seeded> get namedPlants => Map.fromEntries(
        plants.expand(
          (plant) => [
            MapEntry(plant.implementationName, plant),
            if (plant.parent != null) MapEntry(plant.parent!.name, plant),
          ],
        ),
      );

  Iterable<Seeded> plantsOfType(SeededType type) =>
      plants.where((element) => element.type == type);

  Map<String, Seeded> namedPlantsOfType(SeededType type) => Map.fromEntries(
        namedPlants.entries.where((element) => element.value.type == type),
      );

  String onInitTypeOfRef(String generic, {bool nullable = false}) => [
        'OnPineSeedInit<$generic>',
        if (nullable) '?',
      ].join();
}

abstract class Processor<T> {
  const Processor();

  T process(ProcessorContext context);
}
