import 'package:flutter/material.dart';
import 'package:beautician_app/utils/constants.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:beautician_app/views/vender/bottom_navi/screens/dashboard/screens/video_player_screen.dart';

class SalonGalleryCard extends StatelessWidget {
  final List<String> galleryMedia;
  final double padding;

  static const List<QuiltedGridTile> basePattern = [
    QuiltedGridTile(2, 2),
    QuiltedGridTile(1, 1),
    QuiltedGridTile(1, 1),
  ];

  SalonGalleryCard({
    super.key,
    required List<dynamic> galleryMedia,
    this.padding = 10.0,
  }) : galleryMedia = galleryMedia.whereType<String>().toList();

  bool _isVideo(String url) {
    final lower = url.toLowerCase();
    return lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.avi') ||
        lower.endsWith('.mkv') ||
        lower.endsWith('.webm');
  }

  String _getThumbnailUrl(String videoUrl) {
    return videoUrl.replaceAll('.mp4', '.jpg'); // 👈 or use your backend logic
  }

  @override
  Widget build(BuildContext context) {
    if (galleryMedia.isEmpty) {
      return const Center(child: Text('No gallery media available'));
    }

    final pattern = List.generate(
      galleryMedia.length,
      (i) => basePattern[i % basePattern.length],
    );

    final isMobile =
        getDeviceType(MediaQuery.of(context).size) != DeviceScreenType.desktop;
    final crossAxisCount = isMobile ? 2 : 4;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 10),
      child: GridView.custom(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverQuiltedGridDelegate(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          repeatPattern: QuiltedGridRepeatPattern.inverted,
          pattern: pattern,
        ),
        childrenDelegate: SliverChildBuilderDelegate((context, index) {
          final mediaUrl = galleryMedia[index];
          final isVideo = _isVideo(mediaUrl);
          return _buildTile(mediaUrl, isVideo);
        }, childCount: galleryMedia.length),
      ),
    );
  }

  Widget _buildTile(String url, bool isVideo) {
    final displayUrl = isVideo ? _getThumbnailUrl(url) : url;

    return GestureDetector(
      onTap:
          isVideo
              ? () => Get.to(
                () => VideoPlayerScreen(videoPath: url, isNetwork: true),
              )
              : null,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: kCardShadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                displayUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey[200],
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
                errorBuilder:
                    (context, error, stackTrace) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image, size: 40),
                    ),
              ),
              if (isVideo)
                const Center(
                  child: Icon(
                    Icons.play_circle_fill,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
