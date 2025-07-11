// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:ui'; // For ImageFilter.blur

import 'package:scout/domain/entities/activity .dart';
import 'package:scout/domain/entities/activityTranslation .dart';
import 'package:scout/presentation/activityProvider .dart';

class ActivityDetailDialog extends StatefulWidget {
  final Activity activity;
  final ActivityTranslation activityLang;
  final LocalizationProvider localization;
  final bool isMobile;

  const ActivityDetailDialog({
    super.key,
    required this.activity,
    required this.activityLang,
    required this.localization,
    required this.isMobile,
  });

  @override
  State<ActivityDetailDialog> createState() => _ActivityDetailDialogState();
}

class _ActivityDetailDialogState extends State<ActivityDetailDialog> {
  int _currentImageIndex = 0;
  final CarouselSliderController _carouselController =
      CarouselSliderController();
  bool _showDetailsOverlay =
      false; // New state variable to control detail visibility

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth > 800
        ? screenWidth * 0.7
        : screenWidth * 0.9;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: SizedBox(
        width: dialogWidth,
        child: Stack(
          children: [
            // Image Carousel
            CarouselSlider(
              carouselController: _carouselController,
              options: CarouselOptions(
                height: dialogWidth * 0.6,
                viewportFraction: 1.0,
                enlargeCenterPage: false,
                enableInfiniteScroll: widget.activity.pics.length > 1,
                autoPlay: false,
                onPageChanged: (index, reason) {
                  setState(() {
                    _currentImageIndex = index;
                  });
                },
              ),
              items: widget.activity.pics.isEmpty
                  ? [
                      Container(
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: Icon(
                            Icons.photo,
                            size: 100,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ]
                  : widget.activity.pics.map((picUrl) {
                      return Builder(
                        builder: (BuildContext context) {
                          Widget imageWidget = Image.network(
                            picUrl,
                            fit:
                                BoxFit.fill, // Changed to cover for better fill
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  color: Colors.grey.shade300,
                                  child: const Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      size: 100,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                          );

                          // Apply blur and darkening if _showDetailsOverlay is true
                          if (_showDetailsOverlay) {
                            return ImageFiltered(
                              imageFilter: ImageFilter.blur(
                                sigmaX: 2.0,
                                sigmaY: 2.0,
                              ),
                              child: ColorFiltered(
                                colorFilter: ColorFilter.mode(
                                  Colors.black.withOpacity(
                                    0.4,
                                  ), // Adjust opacity for darker effect
                                  BlendMode.darken,
                                ),
                                child: imageWidget,
                              ),
                            );
                          } else {
                            return imageWidget;
                          }
                        },
                      );
                    }).toList(),
            ),

            // Details Overlay
            if (_showDetailsOverlay)
              Positioned.fill(
                child: Container(
                  padding: const EdgeInsets.all(24.0),
                  alignment: Alignment.center,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment:
                          CrossAxisAlignment.center, // Center text horizontally
                      children: [
                        Text(
                          widget.activityLang.title,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                blurRadius: 4.0,
                                color: Colors.black,
                                offset: Offset(2.0, 2.0),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${widget.localization.translate('dateLabel')}: ${widget.activity.date}',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Color.fromARGB(255, 255, 255, 255),
                            shadows: [
                              Shadow(
                                blurRadius: 4.0,
                                color: Colors.black,
                                offset: Offset(2.0, 2.0),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          widget.activityLang.description,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                blurRadius: 4.0,
                                color: Colors.black,
                                offset: Offset(2.0, 2.0),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Close button
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.of(context).pop(),
                style: IconButton.styleFrom(backgroundColor: Colors.black54),
              ),
            ),

            // Toggle Details Button
            Positioned(
              bottom: 8,
              left: 8,
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _showDetailsOverlay = !_showDetailsOverlay;
                  });
                },
                icon: Icon(
                  _showDetailsOverlay ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white,
                ),
                label: Text(
                  _showDetailsOverlay
                      ? widget.localization.translate(
                          'hideDetails',
                        ) // You'll need to add this translation key
                      : widget.localization.translate(
                          'showDetails',
                        ), // You'll need to add this translation key
                  style: const TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black54,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),

            // Indicators for the carousel
            if (widget.activity.pics.length > 1 &&
                !_showDetailsOverlay) // Hide indicators when details are shown
              Positioned(
                bottom: 10.0,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: widget.activity.pics.asMap().entries.map((entry) {
                    return GestureDetector(
                      onTap: () => _carouselController.animateToPage(entry.key),
                      child: Container(
                        width: 8.0,
                        height: 8.0,
                        margin: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 4.0,
                        ),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              (_currentImageIndex == entry.key
                                      ? Colors.blue
                                      : Colors.white)
                                  .withOpacity(0.9),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
