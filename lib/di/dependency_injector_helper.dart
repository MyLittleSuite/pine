/*
 * Copyright (c) 2023 MyLittleSuite
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class DependencyInjectorHelper extends StatelessWidget {
  final List<SingleChildWidget>? mappers;
  final List<SingleChildWidget>? providers;
  final List<RepositoryProvider>? repositories;
  final List<BlocProvider>? blocs;
  final Widget child;

  const DependencyInjectorHelper({
    Key? key,
    this.providers,
    this.repositories,
    this.mappers,
    this.blocs,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (mappers?.isNotEmpty ?? false) {
      return MultiProvider(
        providers: mappers!,
        child: _providers,
      );
    }

    return _providers;
  }

  Widget get _providers {
    if (providers?.isNotEmpty ?? false) {
      return MultiProvider(
        providers: providers!,
        child: _repositories,
      );
    }

    return _repositories;
  }

  Widget get _repositories {
    if (repositories?.isNotEmpty ?? false) {
      return MultiRepositoryProvider(
        providers: repositories!,
        child: _blocs,
      );
    }

    return _blocs;
  }

  Widget get _blocs {
    if (blocs?.isNotEmpty ?? false) {
      return MultiBlocProvider(
        providers: blocs!,
        child: child,
      );
    }

    return child;
  }
}
