// ===============================
// File: gallery_tab_screen.dart
// ===============================
import 'dart:io';
import 'package:beautician_app/controllers/vendors/dashboard/galleryController.dart';
import 'package:beautician_app/controllers/vendors/dashboard/dashboardController.dart';
import 'package:beautician_app/utils/libs.dart';
import 'package:beautician_app/views/vender/bottom_navi/screens/dashboard/screens/video_player_screen.dart';
import 'package:beautician_app/views/widgets/premium_feature_dialogue.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class GalleryTabScreen extends StatelessWidget {
  final GalleryController galleryCtrl = Get.put(GalleryController());
  final DashBoardController dashCtl = Get.put(DashBoardController());

  final List<QuiltedGridTile> basePattern = [
    QuiltedGridTile(2, 2),
    QuiltedGridTile(1, 1),
    QuiltedGridTile(1, 1),
  ];

  @override
  Widget build(BuildContext context) {
    dashCtl.fetchVendor();
    print(dashCtl.gallery);
    return ResponsiveBuilder(
      builder: (context, sizing) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: padding),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Obx(
                  () => CustomButton(
                    title:
                        galleryCtrl.isLoading.value
                            ? "Uploading..."
                            : "Add Pictures / Videos",
                    isEnabled: !galleryCtrl.isLoading.value,
                    onPressed: () {
                      if (dashCtl.listing.value == 'paid') {
                        galleryCtrl.pickGalleryMedia();
                      } else {
                        showPremiumFeatureDialog(context);
                      }
                    },
                  ),
                ),
                const SizedBox(height: 20),
                _buildGalleryGrid(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGalleryGrid() {
    return Obx(() {
      if (dashCtl.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final items = [
        ...dashCtl.gallery.map((url) {
          final isVideo = GalleryItem._isVideo(url);
          final thumb = isVideo ? url.replaceAll('.mp4', '.jpg') : null;
          return GalleryItem.remote(url, thumbnailUrl: thumb);
        }),
        ...galleryCtrl.galleryFiles.map((file) => GalleryItem.local(file)),
      ];

      if (items.isEmpty) {
        return Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Column(
            children: [
              Icon(Icons.photo_library, size: 60, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No media yet',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap the button above to add photos or videos',
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              ),
            ],
          ),
        );
      }

      final pattern = List.generate(
        items.length,
        (i) => basePattern[i % basePattern.length],
      );

      return GridView.custom(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: SliverQuiltedGridDelegate(
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          repeatPattern: QuiltedGridRepeatPattern.inverted,
          pattern: pattern,
        ),
        childrenDelegate: SliverChildBuilderDelegate((ctx, idx) {
          final item = items[idx];
          return item.isLocal ? _buildLocalTile(item) : _buildRemoteTile(item);
        }, childCount: items.length),
      );
    });
  }

  Widget _buildLocalTile(GalleryItem item) {
    final file = item.file!;
    return GestureDetector(
      onTap:
          item.isVideo
              ? () => Get.to(
                () => VideoPlayerScreen(videoPath: file.path, isNetwork: false),
              )
              : null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            item.isVideo
                ? FutureBuilder<File?>(
                  future: _generateThumbnail(file),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasData && snapshot.data != null) {
                      return Image.file(snapshot.data!, fit: BoxFit.cover);
                    }
                    return _videoIconFallback();
                  },
                )
                : Image.file(
                  file,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (ctx, error, stackTrace) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.broken_image, size: 40),
                      ),
                ),
            _buildOverlay(showPlayIcon: item.isVideo),
          ],
        ),
      ),
    );
  }

  Widget _buildRemoteTile(GalleryItem item) {
    final url = item.url!;
    return GestureDetector(
      onTap:
          item.isVideo
              ? () => Get.to(
                () => VideoPlayerScreen(videoPath: url, isNetwork: true),
              )
              : null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            item.isVideo
                ? item.thumbnailUrl != null
                    ? Image.network(
                      item.thumbnailUrl!,
                      fit: BoxFit.cover,
                      loadingBuilder: (ctx, child, progress) {
                        if (progress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                      errorBuilder:
                          (ctx, error, stackTrace) => _videoIconFallback(),
                    )
                    : _videoIconFallback()
                : Image.network(
                  url,
                  fit: BoxFit.cover,
                  loadingBuilder: (ctx, child, progress) {
                    if (progress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value:
                            progress.expectedTotalBytes != null
                                ? progress.cumulativeBytesLoaded /
                                    progress.expectedTotalBytes!
                                : null,
                      ),
                    );
                  },
                  errorBuilder:
                      (ctx, error, stackTrace) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.broken_image, size: 40),
                      ),
                ),
            _buildOverlay(showPlayIcon: item.isVideo),
          ],
        ),
      ),
    );
  }

  Widget _videoIconFallback() {
    return Container(
      color: Colors.black12,
      child: const Center(
        child: Icon(Icons.videocam, size: 40, color: Colors.grey),
      ),
    );
  }

  Widget _buildOverlay({bool showPlayIcon = false}) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Colors.black.withOpacity(0.4), Colors.transparent],
            ),
          ),
        ),
        if (showPlayIcon)
          const Positioned(
            top: 8,
            right: 8,
            child: Icon(
              Icons.play_circle_fill,
              color: Colors.white70,
              size: 50,
            ),
          ),
      ],
    );
  }

  Future<File?> _generateThumbnail(File videoFile) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final thumbPath = await VideoThumbnail.thumbnailFile(
        video: videoFile.path,
        thumbnailPath: tempDir.path,
        imageFormat: ImageFormat.PNG,
        quality: 75,
      );
      return thumbPath != null ? File(thumbPath) : null;
    } catch (_) {
      return null;
    }
  }
}

class GalleryItem {
  final File? file;
  final String? url;
  final String? thumbnailUrl;
  final bool isLocal;
  final bool isVideo;

  static bool _isVideo(String path) {
    final lower = path.toLowerCase();
    return lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.avi') ||
        lower.endsWith('.mkv') ||
        lower.endsWith('.webm');
  }

  GalleryItem.local(this.file)
    : url = null,
      thumbnailUrl = null,
      isLocal = true,
      isVideo = _isVideo(file!.path);

  GalleryItem.remote(this.url, {this.thumbnailUrl})
    : file = null,
      isLocal = false,
      isVideo = _isVideo(url!);
}
