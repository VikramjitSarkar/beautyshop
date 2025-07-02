import 'package:beautician_app/utils/libs.dart';

class SaloonCardThree extends StatelessWidget {
  final String imageUrl;
  final String shopeName;
  final double rating; // Rating out of 5
  final void Function() onTap;
  final String location;

  const SaloonCardThree({
    super.key,
    required this.rating,
    required this.imageUrl,
    required this.shopeName,
    required this.onTap,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 130,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.white,
              border: imageUrl.isNotEmpty? null : Border.all(color: Colors.lightGreen, width: 0.5),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child:
                  imageUrl.isNotEmpty
                      ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) => Image.asset('assets/app icon 2.png'),
                      )
                      : Image.asset('assets/app icon 2.png'),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (int i = 1; i <= 5; i++)
                Padding(
                  padding: const EdgeInsets.only(right: 3),
                  child: Image.asset(
                    i <= rating ? 'assets/star.png' : 'assets/star2.png',
                    height: 16,
                  ),
                ),
              Text(
                rating.toString(),
                style: kHeadingStyle.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Text(
            shopeName,
            style: kHeadingStyle.copyWith(fontSize: 16),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          Text(
            location,
            style: kSubheadingStyle,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}
