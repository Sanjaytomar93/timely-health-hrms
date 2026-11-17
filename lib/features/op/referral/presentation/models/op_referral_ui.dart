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
    this.avatarColor = const Color(0xFF6366F1),
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
    required this.commission,
    required this.totalReferred,
    required this.onboardDate,
    this.avatarColor = const Color(0xFF0D9488),
  });

  final String id;
  final String name;
  final String clinic;
  final String phone;
  final String location;
  final String specialization;
  final bool isActive;
  final String commission;
  final int totalReferred;
  final String onboardDate;
  final Color avatarColor;
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
      avatarColor: Color(0xFF7C3AED),
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
      avatarColor: Color(0xFF4F46E5),
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
      avatarColor: Color(0xFF4338CA),
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
      avatarColor: Color(0xFF6366F1),
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
      avatarColor: Color(0xFF4F46E5),
    ),
  ];

  static const List<OpDoctorReferralUi> demoDoctors = [
    OpDoctorReferralUi(
      id: 'd1',
      name: 'Dr. Suresh Kumar',
      clinic: 'Apollo Clinic & Diagnostics',
      phone: '9848012345',
      location: 'Madhapur',
      specialization: 'General Physician',
      isActive: true,
      commission: '15%',
      totalReferred: 28,
      onboardDate: '12 Aug 2026',
      avatarColor: Color(0xFF0D9488),
    ),
    OpDoctorReferralUi(
      id: 'd2',
      name: 'Dr. Anjali Verma',
      clinic: 'City Care Polyclinic',
      phone: '9988776655',
      location: 'Kondapur',
      specialization: 'Cardiologist',
      isActive: true,
      commission: '20%',
      totalReferred: 18,
      onboardDate: '24 Aug 2026',
      avatarColor: Color(0xFF2563EB),
    ),
    OpDoctorReferralUi(
      id: 'd3',
      name: 'Dr. Ramesh Reddy',
      clinic: 'Metro Health Diagnostics',
      phone: '9700112233',
      location: 'Gachibowli',
      specialization: 'Orthopedics',
      isActive: true,
      commission: '12%',
      totalReferred: 9,
      onboardDate: '05 Sep 2026',
      avatarColor: Color(0xFF7C3AED),
    ),
  ];
}
