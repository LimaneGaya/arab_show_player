import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shows_for_mother/show.dart';
import 'package:url_launcher/url_launcher.dart';

class ShowList extends StatefulWidget {
  const ShowList({super.key});
  @override
  State<ShowList> createState() => _ShowListState();
}

const String likedName = "liked-shows-1";

class _ShowListState extends State<ShowList> {
  List<Show> shows = [];
  late final SharedPreferences prefs;
  List<String> likedShows = [];

  Future<void> addLike(String name) async {
    likedShows.add(name);
    await prefs.setStringList(likedName, likedShows);
    final toRemove = shows.firstWhere((show) => show.name == name);
    shows.remove(toRemove);
    shows.insert(0, toRemove);
    setState(() {});
  }

  Future<void> removeLike(String name) async {
    likedShows.remove(name);
    await prefs.setStringList(likedName, likedShows);
    setState(() {});
  }

  Future<void> getLikedList() async {
    prefs = await SharedPreferences.getInstance();
    final liked = prefs.getStringList(likedName);
    if (liked == null) return;
    setState(() => likedShows = liked);
  }

  @override
  void initState() {
    super.initState();
    Show.getListOfShows()
        .then((s) => setState(() => shows = s))
        .then((value) async => await getLikedList())
        .then((value) {
          for (String s in likedShows) {
            final isInShows = shows.where((show) => show.name == s).toList();
            if (isInShows.isNotEmpty) {
              shows.removeWhere((show) => isInShows.contains(show));
              shows.insertAll(0, isInShows);
            }
          }
          setState(() => shows = shows);
        });
  }

  @override
  Widget build(BuildContext context) {
    return shows.isEmpty
        ? Center(child: CircularProgressIndicator())
        : GridView.builder(
          itemCount: shows.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.6,
          ),

          itemBuilder: (context, index) {
            final s = shows[index];
            return InkWell(
              onTap:
                  () => launchUrl(
                    Uri.parse(s.url),
                    mode: LaunchMode.externalApplication,
                  ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(imageUrl: s.image, fit: BoxFit.cover),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Text(
                      s.length.toString(),
                      textScaler: TextScaler.noScaling,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(blurRadius: 5, color: Colors.black),
                          Shadow(blurRadius: 5, color: Colors.black),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 5,
                    right: 10,
                    child: IconButton(
                      onPressed: () {
                        likedShows.contains(s.name)
                            ? removeLike(s.name)
                            : addLike(s.name);
                      },
                      icon: Icon(
                        likedShows.contains(s.name)
                            ? Icons.favorite
                            : Icons.favorite_border,
                      ),
                      iconSize: 50,
                      color: Colors.red,
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      padding: EdgeInsets.all(5),
                      height: 50,
                      color: Colors.black.withAlpha(230),
                      child: Text(
                        s.name,
                        textScaler: TextScaler.noScaling,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          letterSpacing: -1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
  }
}
