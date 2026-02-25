import 'package:flutter/material.dart';

enum PassType {
  monthly,
  quarterly,
  annual,
  custom,
}

enum PassStatus {
  pending,
  approved,
  rejected,
  active,
  expired,
}

enum PassCategory {
  general,
  student,
  senior,
  employee,
}

class BusPass {
  final String id;
  final String holderName;
  final String holderPhoto;
  final PassType type;
  final PassCategory category;
  final PassStatus status;
  final DateTime applicationDate;
  final DateTime? approvalDate;
  final DateTime validFrom;
  final DateTime validUntil;
  final double fare;
  final String qrCode;
  final List<String> validRoutes;
  final String? studentId;
  final String? employeeId;
  final String? address;

  BusPass({
    required this.id,
    required this.holderName,
    required this.holderPhoto,
    required this.type,
    required this.category,
    required this.status,
    required this.applicationDate,
    this.approvalDate,
    required this.validFrom,
    required this.validUntil,
    required this.fare,
    required this.qrCode,
    required this.validRoutes,
    this.studentId,
    this.employeeId,
    this.address,
  });

  String get typeDisplayName {
    switch (type) {
      case PassType.monthly:
        return 'Monthly Pass';
      case PassType.quarterly:
        return 'Quarterly Pass';
      case PassType.annual:
        return 'Annual Pass';
      case PassType.custom:
        return 'Custom Pass';
    }
  }

  String get categoryDisplayName {
    switch (category) {
      case PassCategory.general:
        return 'General';
      case PassCategory.student:
        return 'Student';
      case PassCategory.senior:
        return 'Senior Citizen';
      case PassCategory.employee:
        return 'Employee';
    }
  }

  Color get statusColor {
    switch (status) {
      case PassStatus.pending:
        return Colors.orange;
      case PassStatus.approved:
      case PassStatus.active:
        return Colors.green;
      case PassStatus.rejected:
        return Colors.red;
      case PassStatus.expired:
        return Colors.grey;
    }
  }

  double get discountPercentage {
    switch (category) {
      case PassCategory.general:
        return 0.0;
      case PassCategory.student:
        return 0.5; // 50% discount
      case PassCategory.senior:
        return 0.3; // 30% discount
      case PassCategory.employee:
        return 0.2; // 20% discount
    }
  }

  int get validityDays {
    switch (type) {
      case PassType.monthly:
        return 30;
      case PassType.quarterly:
        return 90;
      case PassType.annual:
        return 365;
      case PassType.custom:
        return validUntil.difference(validFrom).inDays;
    }
  }
}

class PassApplication {
  final String id;
  final String applicantName;
  final String email;
  final String phone;
  final String address;
  final PassType passType;
  final PassCategory category;
  final DateTime applicationDate;
  final PassStatus status;
  final List<String> documents;
  final String? studentId;
  final String? employeeId;
  final String? rejectionReason;

  PassApplication({
    required this.id,
    required this.applicantName,
    required this.email,
    required this.phone,
    required this.address,
    required this.passType,
    required this.category,
    required this.applicationDate,
    required this.status,
    required this.documents,
    this.studentId,
    this.employeeId,
    this.rejectionReason,
  });
}