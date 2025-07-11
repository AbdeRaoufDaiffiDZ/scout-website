// ignore_for_file: deprecated_member_use

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scout/domain/entities/activity%20.dart';
import 'package:scout/domain/entities/activityTranslation%20.dart';
import 'package:scout/presentation/activityProvider%20.dart';
import 'package:scout/presentation/widgets/activity_detail_dialog.dart';

class ActivitiesSection extends StatefulWidget {
  final LocalizationProvider localization;
  const ActivitiesSection({super.key, required this.localization});

  @override
  State<ActivitiesSection> createState() => _ActivitiesSectionState();
}

class _ActivitiesSectionState extends State<ActivitiesSection> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Fetch initial activities when the widget is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ActivityProvider>(context, listen: false).fetchActivities();
    });

    // Add listener for infinite scrolling
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        // User has scrolled to the end, load more activities
        Provider.of<ActivityProvider>(
          context,
          listen: false,
        ).loadMoreActivities();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activityProvider = Provider.of<ActivityProvider>(
      context,
    ); // Listen to changes

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60.0, horizontal: 16.0),
      color: Colors.grey.shade50,
      child: Column(
        children: [
          Text(
            widget.localization.translate('activitiesHeadline'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 40),
          // Use a ListView.builder or CustomScrollView for infinite scrolling
          // GridView.builder directly inside Column with shrinkWrap: true
          // might not work well with infinite scrolling if the parent is also scrollable.
          // For simplicity, we'll keep GridView.builder but ensure its parent allows scrolling.
          // For true infinite scrolling, it's often better to have the GridView/ListView
          // be the primary scrollable widget or part of a CustomScrollView.
          activityProvider.isLoading && activityProvider.activities.isEmpty
              ? Column(
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                    const SizedBox(height: 20),
                    Text(widget.localization.translate('loadingActivities')),
                  ],
                )
              : activityProvider.errorMessage != null
              ? Text(
                  widget.localization.translate('activitiesError'),
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                )
              : activityProvider.activities.isEmpty &&
                    !activityProvider.isLoading
              ? Text(widget.localization.translate('noActivities'))
              : NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification scrollInfo) {
                    if (scrollInfo.metrics.pixels ==
                            scrollInfo.metrics.maxScrollExtent &&
                        activityProvider.hasMore &&
                        !activityProvider.isFetchingMore) {
                      activityProvider.loadMoreActivities();
                      return true; // Indicate that the notification has been handled.
                    }
                    return false; // Continue bubbling the notification.
                  },
                  child: GridView.builder(
                    controller: _scrollController, // Attach scroll controller
                    shrinkWrap: true,
                    // physics: const NeverScrollableScrollPhysics(), // REMOVE THIS for infinite scrolling
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).size.width > 1200
                          ? 3
                          : MediaQuery.of(context).size.width > 700
                          ? 2
                          : 1,
                      crossAxisSpacing: 24,
                      mainAxisSpacing: 24,
                      childAspectRatio: 0.8, // Adjust based on content height
                    ),
                    itemCount:
                        activityProvider.activities.length +
                        (activityProvider.isFetchingMore
                            ? 1
                            : 0), // Add 1 for loading indicator
                    itemBuilder: (context, index) {
                      if (index == activityProvider.activities.length) {
                        // This is the loading indicator item
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.green,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                widget.localization.translate(
                                  'loadingMoreActivities',
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      final activity = activityProvider.activities[index];
                      final activityLang =
                          widget.localization.locale.languageCode == 'ar'
                          ? activity.translations['ar'] ??
                                activity.translations['en']
                          : activity.translations['en'] ??
                                activity.translations['ar']; // Fallback

                      return ActivityCard(
                        activity: activity,
                        activityLang:
                            activityLang!, // Non-null because of fallback
                        localization: widget.localization,
                      );
                    },
                  ),
                ),
          const SizedBox(height: 40),
          // The "View All Activities" button might not be needed with infinite scrolling,
          // or its logic might need to change to reset pagination and show all from start.
          // For now, I'll keep it but its behavior might be redundant.
          if (!activityProvider.hasMore &&
              !activityProvider.isLoading &&
              !activityProvider.isFetchingMore)
            Text(
              widget.localization.translate('noMoreActivities'),
              style: TextStyle(color: Colors.grey),
            ),

          // Removed the toggleSeeAllActivities button as infinite scrolling handles "view all" implicitly
          // If you still want a "View All" button that perhaps loads ALL activities at once (not recommended for large datasets)
          // or resets the view, its logic would need to be re-evaluated.
        ],
      ),
    );
  }
}

class ActivityCard extends StatefulWidget {
  final Activity activity;
  final ActivityTranslation activityLang;
  final LocalizationProvider localization;

  const ActivityCard({
    super.key,
    required this.activity,
    required this.activityLang,
    required this.localization,
  });

  @override
  State<ActivityCard> createState() => _ActivityCardState();
}

class _ActivityCardState extends State<ActivityCard> {
  int _current = 0; // To track current image index for indicators
  final CarouselSliderController _controller =
      CarouselSliderController(); // To control carousel

  @override
  Widget build(BuildContext context) {
    // Base URL for images, assuming your Node.js server serves them from /uploads
    // If your backend now provides full URLs directly, you don't need to prepend.
    // If paths are like '/uploads/image.png', then prepend your backend URL:
    // const String imageBaseUrl = 'http://localhost:5000';
    // For this example, let's assume `activity.pics` directly contains full URLs.
    const String imageBaseUrl =
        ''; // Or your actual base URL if paths are relative

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior:
          Clip.antiAlias, // Ensures content is clipped to rounded corners
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 2,
            child: Stack(
              children: [
                // Carousel Slider for Images
                CarouselSlider(
                  carouselController: _controller,
                  options: CarouselOptions(
                    height: 250.0, // Fixed height for the carousel
                    viewportFraction: 1.0, // Each item takes full width
                    enlargeCenterPage: false,
                    autoPlay:
                        widget.activity.pics.length >
                        1, // Auto-play if multiple images
                    autoPlayInterval: const Duration(seconds: 5),
                    onPageChanged: (index, reason) {
                      setState(() {
                        _current = index;
                      });
                    },
                  ),
                  items: widget.activity.pics.isEmpty
                      ? [
                          // Show a placeholder if no images
                          Container(
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: Icon(
                                Icons.photo,
                                size: 80,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ]
                      : widget.activity.pics.map((picUrl) {
                          return Builder(
                            builder: (BuildContext context) {
                              final fullImageUrl =
                                  picUrl.startsWith('http') ||
                                      picUrl.startsWith('https')
                                  ? picUrl // Already a full URL
                                  : '$imageBaseUrl$picUrl'; // Prepend base if it's a relative path

                              return Image.network(
                                fullImageUrl,
                                fit: BoxFit.cover,
                                width: MediaQuery.of(
                                  context,
                                ).size.width, // Make image fill width
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      color: Colors.grey.shade300,
                                      child: const Icon(
                                        Icons.broken_image,
                                        size: 80,
                                        color: Colors.red,
                                      ),
                                    ),
                              );
                            },
                          );
                        }).toList(),
                ),
                // Indicators for the carousel
                if (widget.activity.pics.length > 1)
                  Positioned(
                    bottom: 10.0,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: widget.activity.pics.asMap().entries.map((
                        entry,
                      ) {
                        return GestureDetector(
                          onTap: () => _controller.animateToPage(entry.key),
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
                                  (Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white
                                          : Colors.black)
                                      .withOpacity(
                                        _current == entry.key ? 0.9 : 0.4,
                                      ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    widget.activityLang.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: widget.localization.locale.languageCode == 'ar'
                        ? TextAlign.right
                        : TextAlign.left,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.localization.translate('dateLabel')}: ${widget.activity.date}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    textAlign: widget.localization.locale.languageCode == 'ar'
                        ? TextAlign.right
                        : TextAlign.left,
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Text(
                      widget.activityLang.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 4, // Limit lines to fit card height
                      textAlign: widget.localization.locale.languageCode == 'ar'
                          ? TextAlign.right
                          : TextAlign.left,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: widget.localization.locale.languageCode == 'ar'
                        ? Alignment.bottomLeft
                        : Alignment.bottomRight,
                    child: TextButton(
                      onPressed: () {
                        // Action for "Read More" - Show the dialog
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return ActivityDetailDialog(
                              activity: widget.activity,
                              activityLang: widget.activityLang,
                              localization: widget.localization,
                              isMobile: MediaQuery.of(context).size.width < 600,
                            );
                          },
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.green.shade700,
                        backgroundColor: Colors.green.shade50,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      child: Text(widget.localization.translate('readMore')),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
