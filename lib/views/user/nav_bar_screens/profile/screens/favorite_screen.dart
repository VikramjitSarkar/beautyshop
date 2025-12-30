import 'package:responsive_builder/responsive_builder.dart';
import 'package:beautician_app/utils/libs.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../../../controllers/users/profile/getfavourieController.dart';
import '../../home/salon_specialist_detail_screen.dart';
import '../../../../widgets/saloon_card_three.dart';
import '../../../../../data/db_helper.dart';
import '../../../../../controllers/users/auth/genralController.dart';
import '../../../../../constants/globals.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  late final FavoriteFromUserController favFromUserCtrl;

  @override
  void initState() {
    super.initState();
    favFromUserCtrl = Get.find<FavoriteFromUserController>();
    // Force reload favorites when screen opens
    print('FavoriteScreen initState - reloading favorites');
    favFromUserCtrl.loadFavoritesFromUser();
  }

  static const double _pad = 16;

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (_, sizing) {
        final isDesktop = sizing.deviceScreenType == DeviceScreenType.desktop;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(55),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: _pad),
              child: AppBar(
                surfaceTintColor: Colors.transparent,
                backgroundColor: Colors.white,
                leading: Row(children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: SvgPicture.asset('assets/back icon.svg', height: 50),
                  ),
                ]),
                title: const Text(
                  'Favorite',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
          body: Obx(() {
            print('FavoriteScreen: isLoading=${favFromUserCtrl.isLoading.value}, vendorCount=${favFromUserCtrl.vendors.length}');
            
            if (favFromUserCtrl.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            final items = favFromUserCtrl.vendors;
            if (items.isEmpty) {
              return const Center(child: Text('No favorites found.'));
            }

            if (isDesktop) {
              return GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: _pad, vertical: 10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, mainAxisSpacing: 12, crossAxisSpacing: 12, mainAxisExtent: 230,
                ),
                itemCount: items.length,
                itemBuilder: (_, i) => _VendorCard(items[i]),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: _pad, vertical: 10),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => SizedBox(
                height: 230,
                child: _VendorCard(items[i]),
              ),
            );
          }),
        );
      },
    );
  }
}

class _VendorCard extends StatefulWidget {
  const _VendorCard(this.v);
  final Map<String, dynamic> v;

  @override
  State<_VendorCard> createState() => _VendorCardState();
}

class _VendorCardState extends State<_VendorCard> {
  List<String> _categories = [];
  bool _isLoadingCategories = false;

  @override
  void initState() {
    super.initState();
    _fetchVendorCategories();
  }

  Future<void> _fetchVendorCategories() async {
    if (_isLoadingCategories) return;
    setState(() => _isLoadingCategories = true);

    try {
      final vendorId = widget.v['_id'] ?? '';
      print('Fetching categories for vendor $vendorId');
      
      final response = await http.get(
        Uri.parse('${GlobalsVariables.baseUrlapp}/service/byVendorId/$vendorId'),
        headers: {'Accept': 'application/json'},
      );

      print('Categories response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Categories response: $data');
        
        if (data is Map && data['data'] is List) {
          final services = data['data'] as List;
          final cats = <String>{};
          for (final service in services) {
            if (service is Map) {
              // Try both 'category' and 'categoryId'
              final catObj = service['category'] ?? service['categoryId'];
              if (catObj is Map) {
                // Try both 'categoryName' and 'name'
                final catName = catObj['categoryName'] ?? catObj['name'];
                if (catName is String && catName.isNotEmpty) {
                  cats.add(catName);
                }
              }
            }
          }
          print('Extracted ${cats.length} categories: $cats');
          if (mounted) {
            setState(() => _categories = cats.take(3).toList());
          }
        }
      }
    } catch (e) {
      print('Error fetching categories: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingCategories = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final id = (widget.v['_id'] ?? widget.v['id'] ?? '').toString();
    final name = (widget.v['shopName'] ?? widget.v['userName'] ?? widget.v['name'] ?? 'No Name').toString();
    final shopBanner = (widget.v['shopBanner'] ?? widget.v['profileImage'] ?? widget.v['cover'] ?? widget.v['image'] ?? '').toString();
    
    // Debug: Print ALL vendor fields
    print('Vendor $id all fields: ${widget.v.keys.toList()}');
    
    // Try multiple address field names
    final where = (widget.v['locationAddres'] ?? 
                   widget.v['locationAdress'] ?? 
                   widget.v['address'] ?? 
                   widget.v['location'] ?? '').toString();
    
    print('Vendor $id address: locationAddres=${widget.v['locationAddres']}, where=$where');
    
    final distance = (widget.v['distance'] ?? '0').toString();

    double rating = 0.0;
    final rawRating = widget.v['avgRating'] ?? widget.v['rating'] ?? widget.v['shopRating'];
    if (rawRating is num) {
      rating = rawRating.toDouble();
    } else if (rawRating is String) {
      rating = double.tryParse(rawRating) ?? 0.0;
    }

    final galleryImages = (widget.v['galleryImage'] as List?)
            ?.map((e) => e.toString())
            .where((url) => url.isNotEmpty)
            .toList() ??
        [];

    final openingTime = (widget.v['openingTime'] is Map)
        ? Map<String, dynamic>.from(widget.v['openingTime'])
        : <String, dynamic>{};

    return FutureBuilder<bool>(
      future: DBHelper.isFavorite(id),
      builder: (context, favSnapshot) {
        final isFav = favSnapshot.data ?? false;

        return SaloonCardThree(
          distanceKm: distance,
          rating: rating,
          location: where,
          imageUrl: shopBanner,
          shopName: name,
          categories: _categories,
          isFavorite: isFav,
          onFavoriteTap: () {
            final genCtrl = Get.find<GenralController>();
            genCtrl.toggleFavorite(id);
            setState(() {}); // Refresh UI
          },
          onTap: () {
            Get.to(() => SaloonDetailPageScreen(
              phoneNumber: widget.v['phone'] ?? '',
              rating: rating,
              longitude: widget.v['vendorLong'] ?? '',
              latitude: widget.v["vendorLat"] ?? '',
              galleryImage: galleryImages,
              vendorId: id,
              desc: widget.v["description"] ?? '',
              imageUrl: shopBanner,
              location: where,
              openingTime: openingTime,
              shopName: name,
              status: widget.v["status"] ?? '',
              title: widget.v["title"] ?? '',
              userName: widget.v["userName"] ?? name,
              hasPhysicalShop: widget.v["hasPhysicalShop"] ?? false,
              homeServiceAvailable: widget.v["homeServiceAvailable"] ?? false,
            ));
          },
        );
      },
    );
  }
}

