// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'add_to_playlist_cubit.dart';

class AddToPlaylistState {
  MediaItemModel mediaItemModel;
  AddToPlaylistState({required this.mediaItemModel});

  @override
  bool operator ==(covariant AddToPlaylistState other) {
    if (identical(this, other)) return true;

    return other.mediaItemModel == mediaItemModel;
  }

  @override
  int get hashCode => mediaItemModel.hashCode;

  AddToPlaylistState copyWith({MediaItemModel? mediaItemModel}) {
    return AddToPlaylistState(
      mediaItemModel: mediaItemModel ?? this.mediaItemModel,
    );
  }
}

final class AddToPlaylistInitial extends AddToPlaylistState {
  AddToPlaylistInitial() : super(mediaItemModel: mediaItemModelNull);
}
