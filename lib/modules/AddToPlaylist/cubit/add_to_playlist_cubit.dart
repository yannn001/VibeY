// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:bloc/bloc.dart';
import 'package:vibey/models/songModel.dart';
import 'package:vibey/values/Constants.dart';

part 'add_to_playlist_state.dart';

class AddToPlaylistCubit extends Cubit<AddToPlaylistState> {
  AddToPlaylistCubit() : super(AddToPlaylistInitial());

  void setMediaItemModel(MediaItemModel mediaItemModel) {
    emit(state.copyWith(mediaItemModel: mediaItemModel));
  }
}
