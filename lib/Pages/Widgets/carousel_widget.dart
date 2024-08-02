import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class CarouselWidget extends StatelessWidget {
  final List<String> imgList;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;

  const CarouselWidget({
    super.key,
    required this.imgList,
    required this.currentIndex,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: MediaQuery.of(context).size.width * 0.6,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 3),
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        autoPlayCurve: Curves.fastOutSlowIn,
        pauseAutoPlayOnTouch: true,
        aspectRatio: 2.0,
        viewportFraction: 1.0,
        onPageChanged: (index, reason) {
          onPageChanged(index);  // Call the provided callback with the index
        },
      ),
      items: imgList.map((item) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.02),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                image: DecorationImage(
                  image: AssetImage(item),
                  fit: BoxFit.fitHeight,
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}
