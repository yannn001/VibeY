// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:vibey/models/MediaPlaylist.dart';
import 'package:vibey/models/songModel.dart';

class PlaylistModel {
  final String source;
  final String sourceId;
  final String name;
  final String imageURL;
  final String artists;
  final String sourceURL;
  final String? year;
  final String? description;
  final String? language;
  final Map extra;
  final List<MediaItemModel> songs;

  PlaylistModel({
    required this.source,
    required this.sourceId,
    required this.name,
    required this.imageURL,
    required this.artists,
    required this.sourceURL,
    this.description,
    this.year,
    this.language,
    this.extra = const {},
    this.songs = const [],
  });

  get playlist {
    return MediaPlaylist(
      playlistName: name,
      source: source,
      permaURL: sourceURL,
      imgUrl: imageURL,
      mediaItems: songs,
      artists: artists,
      description: description,
      isAlbum: false,
      lastUpdated: DateTime.now(),
    );
  }

  PlaylistModel copyWith({
    String? source,
    String? sourceId,
    String? name,
    String? imageURL,
    String? artists,
    String? sourceURL,
    String? year,
    String? description,
    String? language,
    Map? extra,
    List<MediaItemModel>? songs,
  }) {
    return PlaylistModel(
      source: source ?? this.source,
      sourceId: sourceId ?? this.sourceId,
      name: name ?? this.name,
      imageURL: imageURL ?? this.imageURL,
      artists: artists ?? this.artists,
      sourceURL: sourceURL ?? this.sourceURL,
      year: year ?? this.year,
      description: description ?? this.description,
      language: language ?? this.language,
      extra: extra ?? this.extra,
      songs: songs ?? this.songs,
    );
  }

  @override
  String toString() {
    return 'PlaylistOnlModel(name: $name, imageURL: $imageURL, artists: $artists, sourceURL: $sourceURL, year: $year, description: $description, )';
  }
}

List<PlaylistModel> saavnMap2Playlists(Map<String, dynamic> json) {
  List<PlaylistModel> playlists = [];
  if (json['Playlists'] != null) {
    json['Playlists'].forEach((playlist) {
      playlists.add(
        PlaylistModel(
          name: playlist['title'],
          imageURL: playlist['image'],
          sourceURL: playlist['perma_url'],
          description: playlist['subtitle'],
          artists: playlist['artist'] ?? 'Various Artists',
          source: 'saavn',
          sourceId: playlist['id'],
          year: playlist['year'],
          language: playlist['language'],
        ),
      );
    });
  }
  return playlists;
}

List<PlaylistModel> ytmMap2Playlists(Map<String, dynamic> json) {
  List<PlaylistModel> playlists = [];
  if (json['playlists'] != null) {
    json['playlists'].forEach((playlist) {
      playlists.add(
        PlaylistModel(
          name: playlist['title'],
          imageURL: playlist['image'],
          sourceURL:
              'https://music.youtube.com/playlist?list=${(playlist['id'].toString().replaceAll('youtube', '').replaceFirst('VL', ''))}',
          description: playlist['subtitle'],
          artists: (playlist['artists'] as List)
              .map((e) => e['name'])
              .join(', '),
          source: 'ytm',
          sourceId: playlist['id'],
        ),
      );
    });
  }
  return playlists;
}

List<PlaylistModel> ytvMap2Playlists(Map<String, dynamic> json) {
  List<PlaylistModel> playlists = [];
  if (json['playlists'] != null) {
    json['playlists'].forEach((playlist) {
      playlists.add(
        PlaylistModel(
          source: "youtube",
          sourceId: playlist['id'],
          name: playlist['title'],
          imageURL: playlist['image'],
          artists: "Unknown",
          sourceURL: 'https://www.youtube.com/playlist?list=${playlist['id']}',
        ),
      );
    });
  }
  return playlists;
}
