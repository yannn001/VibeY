import 'package:vibey/theme/default.dart';
import 'package:vibey/utils/load_Image.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';

class SquareImgCard extends StatelessWidget {
  final String imgPath;
  final String title;
  final String subtitle;
  final Function? onTap;
  final String? tag;
  final bool isWide;
  final bool isList;

  const SquareImgCard({
    super.key,
    required this.imgPath,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.isWide = false,
    this.tag,
    this.isList = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: isWide ? 250 : 150,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(36),
              child: Stack(
                children: [
                  SizedBox(
                    height: 155,
                    width: isWide ? 250 : 155,
                    child: LoadImageCached(imageUrl: imgPath),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).scaffoldBackgroundColor,
                ).merge(Default_Theme.secondoryTextStyle),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
