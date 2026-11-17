import 'package:flutter/material.dart';
import 'package:timelay_health/features/op/dashboard/presentation/theme/op_colors.dart';

class OpServiceUi {
  const OpServiceUi({
    required this.id,
    required this.name,
    required this.price,
    required this.createdAt,
    this.description = '',
    this.category = 'Clinical Item',
    this.avatarColor = OpColors.blue,
  });

  final String id;
  final String name;
  final int price;
  final String createdAt;
  final String description;
  final String category;
  final Color avatarColor;

  String get priceLabel => '₹ $price';
  String get initial => name.trim().isEmpty ? 'S' : name.trim()[0].toUpperCase();
  String get descriptionLabel =>
      description.trim().isEmpty ? 'No description provided' : description;

  OpServiceUi copyWith({
    String? name,
    int? price,
    String? description,
    String? createdAt,
    String? category,
  }) {
    return OpServiceUi(
      id: id,
      name: name ?? this.name,
      price: price ?? this.price,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
      category: category ?? this.category,
      avatarColor: avatarColor,
    );
  }
}

class OpServicesUi {
  const OpServicesUi({required this.services});

  final List<OpServiceUi> services;

  static OpServicesUi get demo {
    const date = '06 Nov 2026';
    return const OpServicesUi(
      services: [
        OpServiceUi(
          id: 's1',
          name: 'Ayurvedic Medicine',
          price: 300,
          createdAt: date,
          avatarColor: Color(0xFF3B82F6),
        ),
        OpServiceUi(
          id: 's2',
          name: 'Doctor Consultation Fees',
          price: 600,
          createdAt: date,
          avatarColor: Color(0xFF8B5CF6),
        ),
        OpServiceUi(
          id: 's3',
          name: 'Home Visit',
          price: 1000,
          createdAt: date,
          avatarColor: Color(0xFF10B981),
        ),
        OpServiceUi(
          id: 's4',
          name: 'Ultrasound Scan',
          price: 800,
          createdAt: date,
          avatarColor: Color(0xFF06B6D4),
        ),
        OpServiceUi(
          id: 's5',
          name: 'ECG Test',
          price: 250,
          createdAt: date,
          avatarColor: Color(0xFFF59E0B),
        ),
        OpServiceUi(
          id: 's6',
          name: 'Blood Sugar Test',
          price: 100,
          createdAt: date,
          avatarColor: Color(0xFFEC4899),
        ),
        OpServiceUi(
          id: 's7',
          name: 'Complete Blood Count (CBC)',
          price: 350,
          createdAt: date,
          avatarColor: Color(0xFF6366F1),
        ),
        OpServiceUi(
          id: 's8',
          name: 'Thyroid Profile',
          price: 500,
          createdAt: date,
          avatarColor: Color(0xFF14B8A6),
        ),
        OpServiceUi(
          id: 's9',
          name: 'Vitamin D Test',
          price: 700,
          createdAt: date,
          avatarColor: Color(0xFFF97316),
        ),
        OpServiceUi(
          id: 's10',
          name: 'X-Ray Chest',
          price: 400,
          createdAt: date,
          avatarColor: Color(0xFF0EA5E9),
        ),
        OpServiceUi(
          id: 's11',
          name: 'Dressing Charges',
          price: 150,
          createdAt: '05 Nov 2026',
          avatarColor: Color(0xFF84CC16),
        ),
        OpServiceUi(
          id: 's12',
          name: 'Injection Charges',
          price: 80,
          createdAt: '05 Nov 2026',
          avatarColor: Color(0xFFA855F7),
        ),
        OpServiceUi(
          id: 's13',
          name: 'Nebulization',
          price: 200,
          createdAt: '04 Nov 2026',
          avatarColor: Color(0xFF22C55E),
        ),
        OpServiceUi(
          id: 's14',
          name: 'Physiotherapy Session',
          price: 450,
          createdAt: '04 Nov 2026',
          avatarColor: Color(0xFFEF4444),
        ),
        OpServiceUi(
          id: 's15',
          name: 'Lab Registration Fee',
          price: 50,
          createdAt: '03 Nov 2026',
          avatarColor: Color(0xFF64748B),
        ),
      ],
    );
  }
}
