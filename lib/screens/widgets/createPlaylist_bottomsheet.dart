import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:vibey/services/db/GlobalDB.dart';
import 'package:vibey/services/db/cubit/DBCubit.dart';
import 'package:vibey/theme/default.dart';
import 'package:flutter_animate/flutter_animate.dart';

void createPlaylistBottomSheet(BuildContext context) {
  final _focusNode = FocusNode();
  final _controller = TextEditingController();
  Color textColor = Theme.of(context).textTheme.bodyMedium!.color!;

  showMaterialModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder:
        (context) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.4,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50,
                  height: 5,
                  margin: EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Default_Theme.accentColor2.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ).animate().fadeIn().scale(delay: 100.milliseconds),
                Text(
                  "Create new Playlist",
                  style: TextStyle(
                    color: Default_Theme.accentColor2,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fadeIn().slideY(
                  begin: 0.5,
                  end: 0,
                  delay: 200.milliseconds,
                ),
                SizedBox(height: 30),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    autofocus: true,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      color: Default_Theme.accentColor2,
                    ),
                    decoration: InputDecoration(
                      hintText: "Playlist name",
                      hintStyle: TextStyle(
                        color: Default_Theme.accentColor2.withOpacity(0.5),
                        fontSize: 32,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Default_Theme.accentColor2.withOpacity(0.1),
                    ),
                    onSubmitted: (value) => _createPlaylist(context, value),
                  ).animate().fadeIn().slideY(
                    begin: 0.5,
                    end: 0,
                    delay: 300.milliseconds,
                  ),
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () => _createPlaylist(context, _controller.text),
                  style: ElevatedButton.styleFrom(
                    iconColor: Default_Theme.accentColor2,
                    backgroundColor: Colors.grey[900],
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    "Create",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ).animate().fadeIn().scale(delay: 400.milliseconds),
              ],
            ),
          ),
        ),
  );
}

void _createPlaylist(BuildContext context, String value) {
  if (value.isNotEmpty && value.length > 2) {
    context.read<DBCubit>().addNewPlaylistToDB(
      MediaPlaylistDB(playlistName: value),
    );
    context.pop();
  }
}
