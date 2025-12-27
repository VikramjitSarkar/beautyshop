import 'dart:ui';

import 'package:beautician_app/utils/libs.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

class SaloonCardThree extends StatelessWidget {
  final String imageUrl;
  final String shopName;
  final double rating; // Rating out of 5
  final void Function() onTap;
  final String location;
  final double? etaMinutes;      // e.g. 8.5
  final String distanceKm;      // e.g. 4.5
  final bool isFavorite;         // default false
  final VoidCallback? onFavoriteTap;
  final List<String>? categories; // Categories for this vendor

  const SaloonCardThree({
    super.key,
    required this.rating,
    required this.imageUrl,
    required this.shopName,
    required this.onTap,
    required this.location,
    this.etaMinutes,
    required this.distanceKm,
    this.isFavorite = false,
    this.onFavoriteTap,
    this.categories,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Stack(
        children: [
          // IMAGE
          Container(
            width: double.infinity,            // fill parent row; or keep 130 if you prefer
            height: 200,                       // increased from 180 to accommodate categories
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Colors.white,
              border: imageUrl.isNotEmpty ? null : Border.all(color: Colors.lightGreen, width: 0.5),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: imageUrl.isNotEmpty
                  ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Image.asset('assets/app icon 2.png', fit: BoxFit.cover),
              )
                  : Image.asset('assets/app icon 2.png', fit: BoxFit.cover),
            ),
          ),

          // HEART (top-right)
          Positioned(
            top: 10,
            right: 10,
            child: InkWell(
              onTap: onFavoriteTap,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.25),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  size: 18,
                  color: isFavorite ? const Color(0xFFFF6B6B) : Colors.white,
                ),
              ),
            ),
          ),

          // GOLDEN MATTE GLASS (bottom overlay)
          Positioned(
            left: 0,
            right: 0,
            bottom: 30,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(18),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 500, sigmaY: 500),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(14, 5, 14, 5),
                  decoration: BoxDecoration(
                    // subtle golden tint
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFF5F3EF), // soft beige white
                        Color(0xFFFEFEFE),// pure white
                      ],
                    ),
                    border: Border.all(color: const Color(0x99FFFFFF), width: 0.6),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title + rating stars
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              shopName,
                              style: GoogleFonts.manrope(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // stars + numeric rating
                          Row(
                            children: [
                              for (int i = 1; i <= 5; i++)
                                Padding(
                                  padding: const EdgeInsets.only(right: 2),
                                  child: Icon(
                                    Icons.star_rounded,  // rounded star
                                    size: 15,
                                    color: i <= rating.floor()
                                        ? CupertinoColors.systemYellow
                                        : Colors.grey.shade400,
                                  ),
                                ),

                              const SizedBox(width: 4),

                              Text(
                                rating.toStringAsFixed(1),
                                style: GoogleFonts.manrope(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Address and Distance
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              location ?? '',
                              style: GoogleFonts.manrope(
                                fontSize: 11,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "$distanceKm Km",
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),

                      // Categories (show max 3)
                      if (categories != null && categories!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          children: categories!.take(3).map((cat) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFD4AF37), width: 1),
                              ),
                              child: Text(
                                cat,
                                style: GoogleFonts.manrope(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],

                      const SizedBox(height: 4),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

  }
}
