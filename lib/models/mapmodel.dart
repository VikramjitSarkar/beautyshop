class Category {
  final String id;
  final String image;
  final String name;
  final String status;
  final DateTime createdAt;

  Category({
    required this.id,
    required this.image,
    required this.name,
    required this.status,
    required this.createdAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'],
      image: json['image'],
      name: json['name'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class Vendor {
  final String id;
  final String profileImage;
  final String shopName;
  final double vendorLat;
  final double vendorLong;
  final double distance;

  Vendor({
    required this.id,
    required this.profileImage,
    required this.shopName,
    required this.vendorLat,
    required this.vendorLong,
    required this.distance,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      id: json['_id'],
      profileImage: json['profileImage'],
      shopName: json['shopName'] ?? 'No Shop Name',
      vendorLat: double.parse(json['vendorLat'].toString()),
      vendorLong: double.parse(json['vendorLong'].toString()),
      distance: double.parse(json['distance'].toString()),
    );
  }
}
