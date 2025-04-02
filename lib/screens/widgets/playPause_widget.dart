// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:vibey/theme/default.dart';

class PlayPauseButton extends StatefulWidget {
  final double size;
  final VoidCallback? onPlay;
  final VoidCallback? onPause;
  final bool isPlaying;
  const PlayPauseButton({
    Key? key,
    this.size = 60,
    this.onPlay,
    this.onPause,
    this.isPlaying = false,
  }) : super(key: key);
  @override
  _PlayPauseButtonState createState() => _PlayPauseButtonState();
}

class _PlayPauseButtonState extends State<PlayPauseButton> {
  late bool _isPlaying;
  late Color _currentColor;
  void _togglePlayPause() {
    setState(() {
      _isPlaying ? widget.onPause!() : widget.onPlay!();
      _isPlaying = !_isPlaying;
      _currentColor =
          (_isPlaying
              ? Theme.of(context).textTheme.bodyMedium!.color
              : Theme.of(context).textTheme.bodyMedium!.color)!;
    });
  }

  @override
  Widget build(BuildContext context) {
    double _size = widget.size;
    _isPlaying = widget.isPlaying;
    _currentColor =
        (_isPlaying
            ? Theme.of(context).textTheme.bodyMedium!.color
            : Default_Theme.accentColor1)!;
    return GestureDetector(
      onTap: _togglePlayPause,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentColor,
          ),
          width: _size,
          height: _size,
          child:
              _isPlaying
                  ? Icon(
                    Icons.pause_rounded,
                    size: widget.size * 0.5,
                    color: Theme.of(context).scaffoldBackgroundColor,
                  )
                  : Icon(
                    Icons.play_arrow_rounded,
                    size: widget.size * 0.5,
                    color: Default_Theme.primaryColor1,
                  ),
        ),
      ),
    );
  }
}
