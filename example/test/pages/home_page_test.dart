/*
 * Copyright (c) 2024 MyLittleSuite
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

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/blocs/news/news_bloc.dart';
import 'package:news_app/models/article.dart';
import 'package:news_app/pages/home_page.dart';
import 'package:pine/pine.dart';

class MockNewsBloc extends MockBloc<NewsEvent, NewsState> implements NewsBloc {}

void main() {
  late MockNewsBloc newsBloc;

  setUp(() {
    newsBloc = MockNewsBloc();
  });

  testWidgets('test no news available', (tester) async {
    whenListen(
      newsBloc,
      Stream.fromIterable([
        FetchingNewsState(),
        NoNewsState(),
      ]),
      initialState: FetchingNewsState(),
    );

    await tester.pumpWidget(
      DependencyInjectorHelper(
        blocs: [
          BlocProvider<NewsBloc>.value(value: newsBloc),
        ],
        child: const MaterialApp(
          home: HomePage(),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.text('No news available'), findsOneWidget);
  });

  testWidgets('test news available', (tester) async {
    const articles = [
      Article(title: 'title1', description: 'description1', url: 'url1'),
      Article(title: 'title2', description: 'description2', url: 'url2'),
      Article(title: 'title3', description: 'description3', url: 'url3'),
    ];

    whenListen(
      newsBloc,
      Stream.fromIterable([
        FetchingNewsState(),
        const FetchedNewsState(articles),
      ]),
      initialState: FetchingNewsState(),
    );

    await tester.pumpWidget(
      DependencyInjectorHelper(
        blocs: [
          BlocProvider<NewsBloc>.value(value: newsBloc),
        ],
        child: const MaterialApp(
          home: HomePage(),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();

    for (final article in articles) {
      expect(find.text(article.title), findsOneWidget);
      expect(find.text(article.description), findsOneWidget);
    }
  });

  testWidgets('test error news', (tester) async {
    whenListen(
      newsBloc,
      Stream.fromIterable([
        FetchingNewsState(),
        const ErrorNewsState('error'),
      ]),
      initialState: FetchingNewsState(),
    );

    await tester.pumpWidget(
      DependencyInjectorHelper(
        blocs: [
          BlocProvider<NewsBloc>.value(value: newsBloc),
        ],
        child: const MaterialApp(
          home: HomePage(),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.text('error'), findsOneWidget);
  });
}
