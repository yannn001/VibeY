import 'dart:async';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:go_router/go_router.dart';
import 'package:vibey/theme/default.dart';

class CarouselWidget extends StatefulWidget {
  final List<String> imageUrls;
  final List<String> titles;

  const CarouselWidget({
    Key? key,
    required this.imageUrls,
    required this.titles,
  }) : super(key: key);

  @override
  State<CarouselWidget> createState() => _CarouselWidgetState();
}

class _CarouselWidgetState extends State<CarouselWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: CarouselSlider.builder(
        itemCount: widget.imageUrls.length,
        itemBuilder: (context, index, realIndex) {
          return CarouselItem(
            imageUrl: widget.imageUrls[index],
            title: widget.titles[index],
            onTap: () {
              GoRouter.of(context).pushNamed(
                'ChartScreen',
                pathParameters: {
                  "chartName":
                      widget
                          .titles[index], // Ensure this matches your chart names
                },
              );
            },
          );
        },
        options: CarouselOptions(
          height: 300, // Adjust as needed
          viewportFraction: 0.6,
          autoPlay: true,
          autoPlayInterval: const Duration(seconds: 3),
          enlargeCenterPage: true,
          pauseAutoPlayOnTouch: true,
        ),
      ),
    );
  }
}

class CarouselItem extends StatelessWidget {
  final String imageUrl;
  final String title;
  final VoidCallback onTap; // Tap callback

  const CarouselItem({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.onTap, // Required onTap parameter
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color textColor = Theme.of(context).textTheme.bodyMedium!.color!;
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(25), // Curved background
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // Blurred overlay
          ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: Container(color: Colors.black.withAlpha(179)),
          ),
          // Center curved image
          Positioned(
            top: 20, // Adjust as needed
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                imageUrl,
                width: 135, // Adjust as needed
                height: 160, // Adjust as needed
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Title at the bottom
          Positioned(
            bottom: 20,
            child: Visibility(
              visible: true,
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
