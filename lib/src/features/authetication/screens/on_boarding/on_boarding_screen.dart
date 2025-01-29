import 'package:coded_gp/src/constants/colors.dart';
import 'package:coded_gp/src/constants/image_strings.dart';
import 'package:coded_gp/src/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:liquid_swipe/liquid_swipe.dart';

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
        body: Stack(
      children: [
        LiquidSwipe(
          pages: [
            Container(
              padding: const EdgeInsets.all(
                  value1), // ADD DEFAULT SIZE, for noe its in text strings
              color: whiteColor,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Image(
                    image: AssetImage(onboardingimage1),
                    height: size.height * 0.5,
                  ),
                  Column(
                    children: [
                      Text(
                          onboardingtitle1), // CREATE A THEME FOR THE MAIN HEADING
                      Text(
                        onboardingsubtitle1,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  Text(boardingcounter1),
                  SizedBox(
                    height: 50.0,
                  )
                ],
              ),
            ),
            Container(color: blackColor),
            Container(color: whiteColor),
          ],
        ),
      ], // children
    ));
  }
}
