import 'package:flutter/material.dart';

enum LocationBadgeType {
  hq('HQ', Color(0xFFF1F5F9), Color(0xFF475569), Icons.apartment_rounded, Color(0xFFF1F5F9), Color(0xFF475569)),
  lab('LAB', Color(0xFFECFDF5), Color(0xFF059669), Icons.science_outlined, Color(0xFFECFDF5), Color(0xFF059669)),
  clinic('CLINIC', Color(0xFFEFF6FF), Color(0xFF0284C7), Icons.local_hospital_outlined, Color(0xFFEFF6FF), Color(0xFF0284C7)),
  retail('RETAIL', Color(0xFFF5F3FF), Color(0xFF7C3AED), Icons.local_pharmacy_outlined, Color(0xFFF5F3FF), Color(0xFF7C3AED)),
  corp('CORP', Color(0xFFF8FAFC), Color(0xFF334155), Icons.domain_rounded, Color(0xFFF8FAFC), Color(0xFF334155)),
  branch('BRANCH', Color(0xFFFAF5FF), Color(0xFF9333EA), Icons.storefront_outlined, Color(0xFFFAF5FF), Color(0xFF9333EA));

  const LocationBadgeType(
    this.label,
    this.badgeBg,
    this.badgeColor,
    this.icon,
    this.iconBg,
    this.iconColor,
  );

  final String label;
  final Color badgeBg;
  final Color badgeColor;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
}

class LocationItem {
  final String id;
  final String name;
  final LocationBadgeType badgeType;
  final String address;
  final String city;
  final String state;
  final String pinCode;
  final double latitude;
  final double longitude;
  final bool isActive;

  const LocationItem({
    required this.id,
    required this.name,
    required this.badgeType,
    required this.address,
    required this.city,
    required this.state,
    required this.pinCode,
    required this.latitude,
    required this.longitude,
    required this.isActive,
  });

  LocationItem copyWith({
    String? id,
    String? name,
    LocationBadgeType? badgeType,
    String? address,
    String? city,
    String? state,
    String? pinCode,
    double? latitude,
    double? longitude,
    bool? isActive,
  }) {
    return LocationItem(
      id: id ?? this.id,
      name: name ?? this.name,
      badgeType: badgeType ?? this.badgeType,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      pinCode: pinCode ?? this.pinCode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isActive: isActive ?? this.isActive,
    );
  }

  factory LocationItem.fromJson(Map<String, dynamic> json) {
    final id = (json['_id'] ?? json['id'] ?? '').toString();
    final name = (json['name'] ?? '').toString().trim();
    final rawLat = json['latitude'];
    final rawLng = json['longitude'];
    final latitude = rawLat is num
        ? rawLat.toDouble()
        : (double.tryParse('$rawLat') ?? 0.0);
    final longitude = rawLng is num
        ? rawLng.toDouble()
        : (double.tryParse('$rawLng') ?? 0.0);
    final isActive = json['isActive'] is bool ? json['isActive'] as bool : true;
    final fullAddress =
        (json['fullAddress'] ?? '').toString().replaceAll('\n', ' ').trim();

    final lowerName = name.toLowerCase();
    LocationBadgeType badgeType;
    if (lowerName.contains('corporate') && lowerName.contains('th')) {
      badgeType = LocationBadgeType.hq;
    } else if (lowerName.contains('corporate') || lowerName.contains('ingrain')) {
      badgeType = LocationBadgeType.corp;
    } else if (lowerName.contains('lab')) {
      badgeType = LocationBadgeType.lab;
    } else if (lowerName.contains('clinic')) {
      badgeType = LocationBadgeType.clinic;
    } else if (lowerName.contains('pharmacy')) {
      badgeType = LocationBadgeType.retail;
    } else if (lowerName.contains('vizag')) {
      badgeType = LocationBadgeType.branch;
    } else {
      badgeType = LocationBadgeType.branch;
    }

    final pinMatch = RegExp(r'\b\d{6}\b').firstMatch(fullAddress);
    final pinCode = pinMatch?.group(0) ?? '500081';

    String city;
    final lowerAddr = fullAddress.toLowerCase();
    if (lowerAddr.contains('vizag') || lowerAddr.contains('visakhapatnam')) {
      city = '530016 / Vizag';
    } else if (lowerAddr.contains('secunderabad')) {
      city = 'Secunderabad';
    } else if (lowerAddr.contains('vijayawada')) {
      city = 'Vijayawada';
    } else {
      city = 'Hyderabad';
    }

    String state;
    if (lowerAddr.contains('ap') || lowerAddr.contains('andhra')) {
      state = 'AP.';
    } else if (lowerAddr.contains('telangana')) {
      state = 'Telangana $pinCode';
    } else {
      state = 'Telangana';
    }

    return LocationItem(
      id: id,
      name: name,
      badgeType: badgeType,
      address: fullAddress,
      city: city,
      state: state,
      pinCode: pinCode,
      latitude: latitude,
      longitude: longitude,
      isActive: isActive,
    );
  }

  static List<LocationItem> sampleLocations() {
    return [
      const LocationItem(
        id: '690056b0402066d66998f2ac',
        name: 'TH, Corporate.',
        badgeType: LocationBadgeType.hq,
        address:
            'Falt No: 301, 3rd Floor, Sri Sai Balaji Avenue, H. No: 1-98/9/25/p, Opp Style on Studio, VIP Hills, near Bank of Baroda, Arunodaya Colony, Jaihind Enclave, Madhapur, Hyderabad, Telangana 500081',
        city: 'Hyderabad',
        state: 'Telangana 500081',
        pinCode: '500081',
        latitude: 17.445685,
        longitude: 78.387453,
        isActive: true,
      ),
      const LocationItem(
        id: '690057b0402066d66998f2b1',
        name: 'S-Lab Thanda.',
        badgeType: LocationBadgeType.lab,
        address:
            'H.No: 2, 56/9/C, G-1, Ground floor, Meridian School Rd, beside Mallikarjuna Supper Market, opp. Vegetable Market, Ayyappa Society, Siddhi Vinayak Nagar, Madhapur, Hyderabad, Telangana 500081',
        city: 'Hyderabad',
        state: 'Telangana 500081',
        pinCode: '500081',
        latitude: 17.453893,
        longitude: 78.388982,
        isActive: true,
      ),
      const LocationItem(
        id: '695f5fbae7fe5bdec7436c56',
        name: 'SVV Clinic Thanda.',
        badgeType: LocationBadgeType.clinic,
        address:
            'H.No: 2, 56/9/C, G-1, Ground floor, Meridian School Rd, beside Mallikarjuna Supper Market, opp. Vegetable Market, Ayyappa Society, Siddhi Vinayak Nagar, Madhapur, Hyderabad, Telangana 500081',
        city: 'Hyderabad',
        state: 'Telangana 500081',
        pinCode: '500081',
        latitude: 17.453893,
        longitude: 78.388982,
        isActive: true,
      ),
      const LocationItem(
        id: '695f6058e7fe5bdec7436c59',
        name: 'TH,Pharmacy',
        badgeType: LocationBadgeType.retail,
        address:
            'Falt No: 301, 3rd Floor, Sri Sai Balaji Avenue, H. No: 1-98/9/25/p, Opp Style on Studio, VIP Hills, near Bank of Baroda, Arunodaya Colony, Jaihind Enclave, Madhapur, Hyderabad, Telangana 500081',
        city: 'Hyderabad',
        state: 'Telangana 500081',
        pinCode: '500081',
        latitude: 17.434614,
        longitude: 78.438980,
        isActive: true,
      ),
      const LocationItem(
        id: '6a323583ff53545426d53349',
        name: 'Ingrain,Corporate.',
        badgeType: LocationBadgeType.corp,
        address:
            'Jaya Prakash Nagar, Imam Guda, Padala Ramareddy Colony, Yella Reddy Guda, Hyderabad, Telangana 500073',
        city: 'Hyderabad',
        state: 'Telangana 500073',
        pinCode: '500073',
        latitude: 17.434643,
        longitude: 78.438978,
        isActive: true,
      ),
      const LocationItem(
        id: '6afea9bcc1977c465f8f243b',
        name: 'TH,Vizag',
        badgeType: LocationBadgeType.branch,
        address:
            'Chillapali complex, 47-11-24, 1st Ln, beside Ravindra Bharathi School, Visakhapatnam, 530016, AP.',
        city: '530016 / Vizag',
        state: 'AP.',
        pinCode: '530016',
        latitude: 17.725603,
        longitude: 83.304779,
        isActive: true,
      ),
    ];
  }
}
