// Copyright (C) 2021 d1y <chenhonzhou@gmail.com>
// 
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
// 
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

// import 'package:dio/dio.dart';
// import 'package:movie/impl/movie.dart';
// import 'package:html/parser.dart' as html;
// import 'package:movie/utils/dio.dart';

// class NfmovieMirror extends MovieImpl {
//   // Dio dio = Dio(
//   //   BaseOptions(
//   //     baseUrl: "https://www.nfmovies.com",
//   //     headers: {
//   //       "User-Agent":
//   //           "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:93.0) Gecko/20100101 Firefox/93.0",
//   //       "Accept":
//   //           "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8",
//   //       // "Cookie": "PHPSESSID=551kfnehe39g2t7kcr638v7310; say=hbnl47.57.240.144",
//   //     },
//   //   ),
//   // );

//   @override
//   getDetail(String movie_id) {
//     // TODO: implement getDetail
//     throw UnimplementedError();
//   }

//   @override
//   getHome() async {
//     var resp = await dio.get("https://www.nfmovies.com",
//         options: Options(
//           headers: {
//             "User-Agent":
//                 "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:93.0) Gecko/20100101 Firefox/93.0",
//             "Accept":
//                 "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8",
//             // "Cookie": "PHPSESSID=fec3vu8hu59f8qh8jd58jbabt6; say=hbnl47.57.11.49",
//           },
//         ));
//     var x = resp.toString();
//     print(x);
//     var parser = html.parse(resp.data);
//     var title = parser.querySelector('h3.title');
//     print(title);
//     return [];
//   }

//   @override
//   getSearch(String keyword) {
//     // TODO: implement getSearch
//     throw UnimplementedError();
//   }

//   @override
//   get isNsfw => false;
// }
