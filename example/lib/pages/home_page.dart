/*
 * Copyright (c) 2022 MyLittleSuite
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
import 'package:news_app/blocs/news/news_bloc.dart';
import 'package:news_app/models/article.dart';
import 'package:news_app/pages/webview_page.dart';
import 'package:news_app/widgets/article_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('News App'),
        ),
        body: _body(context),
      );

  Widget _body(BuildContext context) => BlocBuilder<NewsBloc, NewsState>(
        builder: (context, state) {
          if (state is ErrorNewsState) {
            return _errorNewsState(state.error);
          } else if (state is FetchingNewsState) {
            return _loadingNewsState();
          } else if (state is NoNewsState) {
            return _noNewsState();
          } else if (state is FetchedNewsState) {
            return _articles(state.articles);
          }

          return Container();
        },
      );

  Widget _articles(List<Article> articles) => ListView.builder(
        itemCount: articles.length,
        itemBuilder: (context, index) => ArticleWidget(
          articles[index],
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => WebViewPage(articles[index]),
            ),
          ),
        ),
      );

  Widget _errorNewsState(String error) => Center(
        child: Text(error),
      );

  Widget _noNewsState() => const Center(
        child: Text('No news available'),
      );

  Widget _loadingNewsState() => const Center(
        child: CircularProgressIndicator(),
      );
}
