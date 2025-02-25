import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shows_for_mother/show2.dart';
import 'package:shows_for_mother/utils.dart';
import 'package:shows_for_mother/video_player_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class Show2Episodes extends StatefulWidget {
  const Show2Episodes(this.name, this.episodes, {super.key});
  final String name;
  final List<Episode> episodes;
  @override
  State<Show2Episodes> createState() => _Show2EpisodesState();
}

class _Show2EpisodesState extends State<Show2Episodes> {
  late final SharedPreferences pref;
  Future<void> setWatched(Episode ep) async {
    widget.episodes.firstWhere((e) => e.episode == ep.episode).watched = true;
    pref.setStringList(
      widget.name,
      widget.episodes
          .where((s) => s.watched == true)
          .map((s) => s.toString())
          .toList(),
    );
    setState(() {});
  }

  setLiked() async {
    pref = await SharedPreferences.getInstance();
    final watched = pref.getStringList(widget.name);
    if (watched == null) return;
    for (final episode in widget.episodes) {
      if (watched.contains(episode.episode)) {
        episode.watched = true;
      }
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    setLiked();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: GridView.builder(
        itemCount: widget.episodes.length,
        itemBuilder: (context, index) {
          final ep = widget.episodes[index];
          final color =
              ep.videoSource != null
                  ? Colors.white
                  : ep.watchLink != null
                  ? Colors.red.shade300
                  : Colors.red.shade900;
          final number =
              ep.episode
                  .split('/')
                  .firstWhere((e) => e.contains("الحلقة"))
                  .replaceFirst("الحلقة", '')
                  .replaceFirst('-', '')
                  .trim();
          return InkWell(
            onLongPress: (){
              if (ep.watchLink != null) {
                setWatched(ep);
                launchUrl(
                  Uri.parse(ep.watchLink!),
                  mode: LaunchMode.externalApplication,
                );
              }
            },
            onTap: () async {
              if (ep.watchLink == null) {
                setWatched(ep);
                launchUrl(
                  Uri.parse(ep.episode),
                  mode: LaunchMode.externalApplication,
                );
              }
              final link = await extractVideoSource(ep.watchLink!);
              if (link == null) {
                launchUrl(
                  Uri.parse(ep.watchLink!),
                  mode: LaunchMode.externalApplication,
                );
                setWatched(ep);
                return;
              }
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => VideoPlayerScreen(link),
                ),
              );
              setWatched(ep);
            },
            child: ColoredBox(
              color:
                  ep.watched
                      ? Colors.green.shade800.withAlpha(200)
                      : Colors.transparent,
              child: Center(
                child: Text(
                  number,
                  textScaler: TextScaler.noScaling,
                  style: TextStyle(
                    color: color,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(blurRadius: 5, color: Colors.black),
                      Shadow(blurRadius: 5, color: Colors.black),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 1.6,
          mainAxisSpacing: 2,
          crossAxisSpacing: 2,
        ),
      ),
    );
  }
}
