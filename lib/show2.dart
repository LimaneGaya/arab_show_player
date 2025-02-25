import 'dart:convert';
import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/services.dart' show rootBundle;

List<Show2> back(String s) {
  final j = jsonDecode(s) as List;
  final m = j.map((s) => Show2.fromJson(s as Map<String, dynamic>)).toList();
  return m;
}

class Episode {
  final String episode;
  final String? watchLink;
  final String? videoSource;
  bool watched = false;
  Episode(
    this.episode,
    this.watchLink,
    this.videoSource, [
    this.watched = false,
  ]);
  factory Episode.fromJson(dynamic json) {
    switch (json) {
      case {
        "episode_link": String e,
        "watch_link": String w,
        "video_src": String v,
      }:
        return Episode(e, w, v);
      case {"episode_link": String e, "watch_link": String w}:
        return Episode(e, w, null);
      case {"episode_link": String e}:
        return Episode(e, null, null);
    }

    throw Exception('Could not convert to class Episode');
  }
  @override
  String toString() => episode;
}

class Show2 {
  final String name;
  final int length;
  final String url;
  final String image;
  final List<Episode> episodes;
  const Show2(this.name, this.length, this.url, this.image, this.episodes);
  factory Show2.fromJson(dynamic json) {
    if (json case {
      "link": String u,
      "image": String i,
      "name": String n,
      "episodes": List l,
    }) {
      final na = n.trim();
      return Show2(
        na,
        l.length,
        u,
        i,
        l.map((epi) => Episode.fromJson(epi)).toList(),
      );
    } else {
      throw Exception('Could not convert to class show2');
    }
  }
  static Future<List<Show2>> getListOfShows() async {
    String file = await rootBundle.loadString("assets/show_list_2.json");
    final map = await compute(back, file);
    return map;
  }
}
