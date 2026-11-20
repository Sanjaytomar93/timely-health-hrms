import 'package:flutter/material.dart';

class OpCustomerReferralUi {
  const OpCustomerReferralUi({
    required this.id,
    required this.name,
    required this.organization,
    required this.phone,
    required this.location,
    required this.isActive,
    required this.serviceRate,
    required this.pharmacyRate,
    required this.labRate,
    required this.fees,
    required this.onboardDate,
    this.avatarColor = const Color(0xFF26204A),
    this.specialFees = '0',
    this.specialLab = '0',
    this.specialPharmacy = '0',
    this.opCount = 1,
    this.revenue = '₹30',
    this.notes = '',
  });

  final String id;
  final String name;
  final String organization;
  final String phone;
  final String location;
  final bool isActive;
  final String serviceRate;
  final String pharmacyRate;
  final String labRate;
  final String fees;
  final String onboardDate;
  final Color avatarColor;
  final String specialFees;
  final String specialLab;
  final String specialPharmacy;
  final int opCount;
  final String revenue;
  final String notes;

  OpCustomerReferralUi copyWith({
    String? id,
    String? name,
    String? organization,
    String? phone,
    String? location,
    bool? isActive,
    String? serviceRate,
    String? pharmacyRate,
    String? labRate,
    String? fees,
    String? onboardDate,
    Color? avatarColor,
    String? specialFees,
    String? specialLab,
    String? specialPharmacy,
    int? opCount,
    String? revenue,
    String? notes,
  }) {
    return OpCustomerReferralUi(
      id: id ?? this.id,
      name: name ?? this.name,
      organization: organization ?? this.organization,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      isActive: isActive ?? this.isActive,
      serviceRate: serviceRate ?? this.serviceRate,
      pharmacyRate: pharmacyRate ?? this.pharmacyRate,
      labRate: labRate ?? this.labRate,
      fees: fees ?? this.fees,
      onboardDate: onboardDate ?? this.onboardDate,
      avatarColor: avatarColor ?? this.avatarColor,
      specialFees: specialFees ?? this.specialFees,
      specialLab: specialLab ?? this.specialLab,
      specialPharmacy: specialPharmacy ?? this.specialPharmacy,
      opCount: opCount ?? this.opCount,
      revenue: revenue ?? this.revenue,
      notes: notes ?? this.notes,
    );
  }
}

class OpDoctorReferralUi {
  const OpDoctorReferralUi({
    required this.id,
    required this.name,
    required this.clinic,
    required this.phone,
    required this.location,
    required this.specialization,
    required this.isActive,
    required this.serviceRate,
    required this.pharmacyRate,
    required this.labRate,
    required this.fees,
    required this.onboardDate,
    this.avatarColor = const Color(0xFF26204A),
    this.opCount = 2,
    this.revenue = '₹0',
    this.address = 'KSR ENCLAVE PLOT NO 42, APARNA HILLPARK, CHANDA NAGAR, HYDERABAD',
    this.commission = '40%',
    this.totalReferred = 2,
    this.specialFees = '0',
    this.specialLab = '0',
    this.specialPharmacy = '0',
    this.notes = '',
  });

  final String id;
  final String name;
  final String clinic;
  final String phone;
  final String location;
  final String specialization;
  final bool isActive;
  final String serviceRate;
  final String pharmacyRate;
  final String labRate;
  final String fees;
  final String onboardDate;
  final Color avatarColor;
  final int opCount;
  final String revenue;
  final String address;
  final String commission;
  final int totalReferred;
  final String specialFees;
  final String specialLab;
  final String specialPharmacy;
  final String notes;

  OpDoctorReferralUi copyWith({
    String? id,
    String? name,
    String? clinic,
    String? phone,
    String? location,
    String? specialization,
    bool? isActive,
    String? serviceRate,
    String? pharmacyRate,
    String? labRate,
    String? fees,
    String? onboardDate,
    Color? avatarColor,
    int? opCount,
    String? revenue,
    String? address,
    String? commission,
    int? totalReferred,
    String? specialFees,
    String? specialLab,
    String? specialPharmacy,
    String? notes,
  }) {
    return OpDoctorReferralUi(
      id: id ?? this.id,
      name: name ?? this.name,
      clinic: clinic ?? this.clinic,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      specialization: specialization ?? this.specialization,
      isActive: isActive ?? this.isActive,
      serviceRate: serviceRate ?? this.serviceRate,
      pharmacyRate: pharmacyRate ?? this.pharmacyRate,
      labRate: labRate ?? this.labRate,
      fees: fees ?? this.fees,
      onboardDate: onboardDate ?? this.onboardDate,
      avatarColor: avatarColor ?? this.avatarColor,
      opCount: opCount ?? this.opCount,
      revenue: revenue ?? this.revenue,
      address: address ?? this.address,
      commission: commission ?? this.commission,
      totalReferred: totalReferred ?? this.totalReferred,
      specialFees: specialFees ?? this.specialFees,
      specialLab: specialLab ?? this.specialLab,
      specialPharmacy: specialPharmacy ?? this.specialPharmacy,
      notes: notes ?? this.notes,
    );
  }
}

class OpReferralData {
  static const List<OpCustomerReferralUi> demoCustomers = [
    OpCustomerReferralUi(
      id: '1',
      name: 'SRINIVAS',
      organization: 'SRI CHAITANYA COLLE...',
      phone: '9579866226',
      location: 'MADHAPUR',
      isActive: true,
      serviceRate: '10%',
      pharmacyRate: '20%',
      labRate: '40%',
      fees: '150%',
      onboardDate: '01 Sept 2026',
      avatarColor: Color(0xFF26204A),
    ),
    OpCustomerReferralUi(
      id: '2',
      name: 'lalitha heights ( narayana )',
      organization: 'maniteja',
      phone: '6361708489',
      location: 'N/A',
      isActive: true,
      serviceRate: '0%',
      pharmacyRate: '0%',
      labRate: '0%',
      fees: '0%',
      onboardDate: '27 Oct 2026',
      avatarColor: Color(0xFF26204A),
    ),
    OpCustomerReferralUi(
      id: '3',
      name: 'Naveen Naidu',
      organization: 'Narayana College URBA...',
      phone: '8374328363',
      location: 'N/A',
      isActive: true,
      serviceRate: '10%',
      pharmacyRate: '10%',
      labRate: '20%',
      fees: '₹100',
      onboardDate: '01 Oct 2026',
      avatarColor: Color(0xFF26204A),
    ),
    OpCustomerReferralUi(
      id: '4',
      name: 'Beeswndra',
      organization: 'Naraya IIT CO B Block',
      phone: '7569192030',
      location: 'Madhapur',
      isActive: true,
      serviceRate: '10%',
      pharmacyRate: '10%',
      labRate: '20%',
      fees: '₹150',
      onboardDate: '10 Oct 2026',
      avatarColor: Color(0xFF26204A),
    ),
    OpCustomerReferralUi(
      id: '5',
      name: 'RAMESH',
      organization: 'N/A',
      phone: '8553588055',
      location: 'MADHAPUR',
      isActive: true,
      serviceRate: '0%',
      pharmacyRate: '0%',
      labRate: '0%',
      fees: '₹150',
      onboardDate: '06 Oct 2026',
      avatarColor: Color(0xFF26204A),
    ),
  ];

  static const List<OpDoctorReferralUi> demoDoctors = [
    OpDoctorReferralUi(
      id: '6ae6dc3e1393a0133685d29f',
      name: 'Dr MURALI BHASKAR',
      clinic: 'AM CLINICS',
      phone: 'N/A',
      location: 'CHANDA NAGAR, HYDERABAD',
      address: 'KSR ENCLAVE PLOT NO 42, APARNA HILLPARK, CHANDA NAGAR, HYDERABAD',
      specialization: 'FAMILY PHYSICIAN',
      isActive: true,
      serviceRate: '0%',
      pharmacyRate: '0%',
      labRate: '40%',
      fees: '0%',
      onboardDate: '01 Apr 2026',
      opCount: 2,
      revenue: '₹0',
      commission: '40%',
      totalReferred: 2,
      avatarColor: Color(0xFF26204A),
    ),
    OpDoctorReferralUi(
      id: '6ae6dc3e1393a0133685d29e',
      name: 'Dr SWETHA CHAVAN',
      clinic: 'CHAVANS CLINIC',
      phone: '8309657861',
      location: 'KONDAPUR, HYDERABAD',
      address: 'PLOT NO 102, KONDAPUR MAIN ROAD, HYDERABAD',
      specialization: 'HARI TRANSPLANTATION SPECILIST',
      isActive: true,
      serviceRate: '0%',
      pharmacyRate: '0%',
      labRate: '50%',
      fees: '0%',
      onboardDate: '01 Jan 2025',
      opCount: 8,
      revenue: '₹0',
      commission: '50%',
      totalReferred: 8,
      avatarColor: Color(0xFF26204A),
    ),
    OpDoctorReferralUi(
      id: '6ae6dc3e1393a0133685d29d',
      name: 'DR G VIJAY KUMAR',
      clinic: 'PULSE HEALTH CLINIC',
      phone: '7396639211',
      location: 'GACHIBOWLI, HYDERABAD',
      address: 'PULSE HEALTH COMPLEX, GACHIBOWLI, HYDERABAD',
      specialization: 'MS SURGEN',
      isActive: true,
      serviceRate: '0%',
      pharmacyRate: '0%',
      labRate: '40%',
      fees: '0%',
      onboardDate: '01 Jan 2026',
      opCount: 6,
      revenue: '₹0',
      commission: '40%',
      totalReferred: 6,
      avatarColor: Color(0xFF26204A),
    ),
  ];
}
