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

import 'package:news_app/models/article.dart';
import 'package:news_app/services/responses/article_dto.dart';
import 'package:pine/pine.dart';

class ArticleMapper extends DTOMapper<ArticleDTO, Article> {
  @override
  Article fromDTO(ArticleDTO dto) => Article(
        title: dto.title,
        description: dto.description,
        urlToImage: dto.urlToImage,
        url: dto.url,
        publishedAt: dto.publishedAt,
        content: dto.content,
      );

  @override
  DTO toDTO(Article model) => ArticleDTO(
        title: model.title,
        description: model.description,
        urlToImage: model.urlToImage,
        url: model.url,
        publishedAt: model.publishedAt,
        content: model.content,
      );
}
