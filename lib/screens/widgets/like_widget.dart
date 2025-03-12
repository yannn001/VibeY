import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:vibey/theme/default.dart';
import 'package:icons_plus/icons_plus.dart';

// ignore: must_be_immutable
class LikeBtnWidget extends StatefulWidget {
  bool isLiked;
  final bool isPlaying;
  final double iconSize;
  final VoidCallback? onLiked;
  final VoidCallback? onDisliked;
  LikeBtnWidget({
    Key? key,
    this.isLiked = false,
    this.isPlaying = false,
    this.iconSize = 50,
    this.onLiked,
    this.onDisliked,
  }) : super(key: key);

  @override
  State<LikeBtnWidget> createState() => _LikeBtnWidgetState();
}

class _LikeBtnWidgetState extends State<LikeBtnWidget> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        setState(() {
          widget.isLiked = !widget.isLiked;
          if (widget.isLiked) {
            widget.onLiked!();
            log("Liked");
          } else {
            widget.onDisliked!();
            log("DisLiked");
          }
        });
      },
      icon:
          widget.isPlaying
              ? heartIcon(
                color: Colors.pink,
                size: widget.iconSize,
                isliked: widget.isLiked,
              )
              : heartIcon(isliked: widget.isLiked, size: widget.iconSize),
    );
  }
}

Icon heartIcon({isliked = false, color = Colors.blueGrey, size = 50}) {
  return isliked
      ? Icon(Icons.favorite_rounded, color: color, size: size)
      : Icon(Icons.favorite_border_rounded, color: color, size: size);
}
