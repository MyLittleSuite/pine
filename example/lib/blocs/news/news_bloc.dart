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

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app/models/article.dart';
import 'package:news_app/repositories/news_repository.dart';

part 'news_event.dart';
part 'news_state.dart';

class NewsBloc extends Bloc<NewsEvent, NewsState> {
  final NewsRepository newsRepository;

  NewsBloc({required this.newsRepository}) : super(FetchingNewsState()) {
    on<FetchNewsEvent>(_mapFetchNewsEventToState);
  }

  void fetchNews() => add(FetchNewsEvent());

  void _mapFetchNewsEventToState(_, Emitter<NewsState> emit) async {
    emit(FetchingNewsState());

    List<Article>? articles;
    try {
      articles = await newsRepository.news;
    } catch (error) {
      emit(ErrorNewsState(error.toString()));
    }

    if (articles != null) {
      if (articles.isNotEmpty) {
        emit(FetchedNewsState(articles));
      } else {
        emit(NoNewsState());
      }
    } else {
      const ErrorNewsState('Generic error');
    }
  }
}
