import 'dart:ui';

import 'package:beautician_app/utils/libs.dart';
import 'package:google_fonts/google_fonts.dart';

class SaloonCardFour extends StatelessWidget {
  final String imageUrl;
  final String shopeName;
  final double rating; // Rating out of 5
  final void Function() onTap;
  final String location;
  final double? etaMinutes;      // e.g. 8.5
  final double? distanceKm;      // e.g. 4.5
  final bool isFavorite;         // default false
  final VoidCallback? onFavoriteTap;

  const SaloonCardFour({
    super.key,
    required this.rating,
    required this.imageUrl,
    required this.shopeName,
    required this.onTap,
    required this.location,
    this.etaMinutes,
    this.distanceKm,
    this.isFavorite = false,
    this.onFavoriteTap,
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
            height: 180,                       // adjust to your layout
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
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  decoration: BoxDecoration(
                    // subtle golden tint
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0x66E3DFD5), // pale gold
                        Color(0x33FFFFFF), // gold
                      ],
                    ),
                    border: Border.all(color: const Color(0x99FFFFFF), width: 0.6),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shopeName,
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 6),
                      // Title + rating stars
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [

                          // stars + numeric rating
                          Row(
                            children: [
                              for (int i = 1; i <= 5; i++)
                                Padding(
                                  padding: const EdgeInsets.only(right: 3),
                                  child: Image.asset(
                                    i <= rating ? 'assets/star.png' : 'assets/star2.png',
                                    height: 14,
                                  ),
                                ),
                              Text(
                                  rating.toStringAsFixed(1),
                                  style: GoogleFonts.manrope(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  )
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Address
                      Text(
                        location,
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // ETA + distance (optional; shows only if provided)
                      if (etaMinutes != null || distanceKm != null) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 16, color: Colors.black87),
                            const SizedBox(width: 6),
                            Text(
                              [
                                if (etaMinutes != null) '${etaMinutes!.toStringAsFixed(1)} min',
                                if (distanceKm != null) '(${distanceKm!.toStringAsFixed(1)} km)',
                              ].join(' '),
                              style: GoogleFonts.manrope(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 10),
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
