part of 'Recently_cubit.dart';

class RecentlyState {
  MediaPlaylist mediaPlaylist;
  RecentlyState({required this.mediaPlaylist});

  RecentlyState copyWith({MediaPlaylist? mediaPlaylist}) {
    return RecentlyState(mediaPlaylist: mediaPlaylist ?? this.mediaPlaylist);
  }
}

class RecentlyInitial extends RecentlyState {
  RecentlyInitial()
    : super(mediaPlaylist: MediaPlaylist(playlistName: "", mediaItems: []));
}
