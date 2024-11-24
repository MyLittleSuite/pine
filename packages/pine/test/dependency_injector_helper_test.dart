import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pine/pine.dart';
import 'package:provider/provider.dart';

import 'mocks/demo_bloc.dart';
import 'mocks/demo_repository.dart';
import 'mocks/demo_service.dart';
import 'mocks/string_mapper.dart';

void main() {
  group('test hierarchy', () {
    testWidgets('test right order of injections', (tester) async {
      tester.pumpWidget(
        DependencyInjectorHelper(
          mappers: [
            Provider<Mapper<String, int>>(
              create: (_) => StringMapper(),
            ),
          ],
          providers: [
            Provider<DemoService>(
              create: (_) => DemoServiceImpl(),
            ),
          ],
          repositories: [
            RepositoryProvider<DemoRepository>(
              create: (_) => DemoRepositoryImpl(),
            ),
          ],
          blocs: [
            BlocProvider<DemoBloc>(
              create: (_) => DemoBloc(),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(),
          ),
        ),
      );

      find.ancestor(
        of: find.byType(MaterialApp),
        matching: find.byType(BlocProvider<DemoBloc>),
      );

      find.ancestor(
        of: find.byType(BlocProvider<DemoBloc>),
        matching: find.byType(RepositoryProvider<DemoRepository>),
      );

      find.ancestor(
        of: find.byType(RepositoryProvider<DemoRepository>),
        matching: find.byType(Provider<DemoService>),
      );

      find.ancestor(
        of: find.byType(Provider<DemoService>),
        matching: find.byType(Mapper<String, int>),
      );
    });
  });
}
