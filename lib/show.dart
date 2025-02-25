import 'dart:convert';
import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/services.dart' show rootBundle;

List<Show> back(String s) {
  final j = jsonDecode(s) as List;
  final m = j.map((s) => Show.fromJson(s as Map<String, dynamic>)).toList();
  return m;
}

class Show {
  final String name;
  final int length;
  final String url;
  final String image;
  const Show(this.name, this.length, this.url, this.image);
  factory Show.fromJson(dynamic json) {
    if (json case {
      'url': String u,
      'image': String i,
      'episodes': int l,
      'name': String n,
    }) {
      final na = n.replaceFirst('مسلسل', '').replaceFirst('مدبلج', '').trim();
      return Show(na, l, u, i);
    } else {
      throw Exception('Could not convert to class show');
    }
  }
  static Future<List<Show>> getListOfShows() async {
    String file = await rootBundle.loadString("assets/show_list.json");
    final map = await compute(back, file);
    return map;
  }
}
