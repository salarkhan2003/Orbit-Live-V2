import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

import '../../../../core/firebase_database_service.dart';
import '../../domain/pass_models.dart';

import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;

import '../../../bookings/data/booking_service.dart'; // Add booking service
import '../../../bookings/domain/booking_models.dart'; // Add booking models

class PassProvider with ChangeNotifier {
  List<BusPass> _passes = [];
  List<PassApplication> _applications = [];
  bool _isProcessingApplication = false;
  BusPass? _generatedPass;
  StreamSubscription? _passesSubscription;

  List<BusPass> get passes => _passes;
  List<PassApplication> get applications => _applications;
  bool get isProcessingApplication => _isProcessingApplication;
  BusPass? get generatedPass => _generatedPass;

  Future<void> submitApplicationWithPayment(PassApplication application) async {
    _isProcessingApplication = true;
    _generatedPass = null;
    notifyListeners();

    // Calculate pass fare
    final double passFare = _calculatePassFare(application.passType, application.category);

    // Add application to list
    _applications.add(application);

    // Auto-approve the application (mock prototype behavior)
    final approvedApplication = PassApplication(
      id: application.id,
      applicantName: application.applicantName,
      email: application.email,
      phone: application.phone,
      address: application.address,
      passType: application.passType,
      category: application.category,
      applicationDate: application.applicationDate,
      status: PassStatus.approved,
      documents: application.documents,
      studentId: application.studentId,
      employeeId: application.employeeId,
    );

    // Update application in list
    final index = _applications.indexWhere((app) => app.id == application.id);
    if (index != -1) {
      _applications[index] = approvedApplication;
    }

    // Generate pass
    var pass = BusPass(
      id: 'PASS${DateTime.now().millisecondsSinceEpoch}',
      holderName: application.applicantName,
      holderPhoto: 'assets/images/default_avatar.png',
      type: application.passType,
      category: application.category,
      status: PassStatus.active,
      applicationDate: application.applicationDate,
      approvalDate: DateTime.now(),
      validFrom: DateTime.now(),
      validUntil: _calculateValidUntil(application.passType),
      fare: passFare,
      qrCode: 'ORBIT_PASS_${DateTime.now().millisecondsSinceEpoch}',
      validRoutes: ['All Routes'], // For simplicity, all routes are valid
      studentId: application.studentId,
      employeeId: application.employeeId,
      address: application.address,
    );

    // Store pass in Firestore using the new booking service
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Create booking record
        final bookingId = await BookingService.createBooking(
          type: BookingType.pass,
          source: 'Pass Application',
          destination: '${application.passType.name} pass for ${application.category.name}',
          fare: passFare,
          travelDate: DateTime.now(),
          paymentStatus: PaymentStatus.success,
          transactionId: 'UPI_${DateTime.now().millisecondsSinceEpoch}',
          qrCode: pass.qrCode,
        );
        
        // Update pass ID with booking ID
        final updatedPass = BusPass(
          id: bookingId,
          holderName: pass.holderName,
          holderPhoto: pass.holderPhoto,
          type: pass.type,
          category: pass.category,
          status: pass.status,
          applicationDate: pass.applicationDate,
          approvalDate: pass.approvalDate,
          validFrom: pass.validFrom,
          validUntil: pass.validUntil,
          fare: pass.fare,
          qrCode: pass.qrCode,
          validRoutes: pass.validRoutes,
          studentId: pass.studentId,
          employeeId: pass.employeeId,
          address: pass.address,
        );
        
        pass = updatedPass;
      }
    } catch (e) {
      debugPrint('Error storing pass in Firestore: $e');
    }

    _passes.add(pass);
    _generatedPass = pass;
    _isProcessingApplication = false;
    notifyListeners();
  }

  // New method for processing Cashfree payments for passes
  Future<void> submitApplicationWithCashfreePayment(
    PassApplication application,
    String transactionId,
  ) async {
    _isProcessingApplication = true;
    _generatedPass = null;
    notifyListeners();

    // Calculate pass fare
    final double passFare = _calculatePassFare(application.passType, application.category);

    // Add application to list
    _applications.add(application);

    // Auto-approve the application (mock prototype behavior)
    final approvedApplication = PassApplication(
      id: application.id,
      applicantName: application.applicantName,
      email: application.email,
      phone: application.phone,
      address: application.address,
      passType: application.passType,
      category: application.category,
      applicationDate: application.applicationDate,
      status: PassStatus.approved,
      documents: application.documents,
      studentId: application.studentId,
      employeeId: application.employeeId,
    );

    // Update application in list
    final index = _applications.indexWhere((app) => app.id == application.id);
    if (index != -1) {
      _applications[index] = approvedApplication;
    }

    // Generate pass
    var pass = BusPass(
      id: 'PASS${DateTime.now().millisecondsSinceEpoch}',
      holderName: application.applicantName,
      holderPhoto: 'assets/images/default_avatar.png',
      type: application.passType,
      category: application.category,
      status: PassStatus.active,
      applicationDate: application.applicationDate,
      approvalDate: DateTime.now(),
      validFrom: DateTime.now(),
      validUntil: _calculateValidUntil(application.passType),
      fare: passFare,
      qrCode: 'ORBIT_PASS_${DateTime.now().millisecondsSinceEpoch}',
      validRoutes: ['All Routes'], // For simplicity, all routes are valid
      studentId: application.studentId,
      employeeId: application.employeeId,
      address: application.address,
    );

    // Store pass in Firestore with payment information using the new booking service
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Create booking record
        final bookingId = await BookingService.createBooking(
          type: BookingType.pass,
          source: 'Pass Application',
          destination: '${application.passType.name} pass for ${application.category.name}',
          fare: passFare,
          travelDate: DateTime.now(),
          paymentStatus: PaymentStatus.success,
          transactionId: transactionId,
          qrCode: pass.qrCode,
        );
        
        // Update pass ID with booking ID
        final updatedPass = BusPass(
          id: bookingId,
          holderName: pass.holderName,
          holderPhoto: pass.holderPhoto,
          type: pass.type,
          category: pass.category,
          status: pass.status,
          applicationDate: pass.applicationDate,
          approvalDate: pass.approvalDate,
          validFrom: pass.validFrom,
          validUntil: pass.validUntil,
          fare: pass.fare,
          qrCode: pass.qrCode,
          validRoutes: pass.validRoutes,
          studentId: pass.studentId,
          employeeId: pass.employeeId,
          address: pass.address,
        );
        
        pass = updatedPass;
      }
    } catch (e) {
      debugPrint('Error storing pass in Firestore: $e');
    }

    _passes.add(pass);
    _generatedPass = pass;
    _isProcessingApplication = false;
    notifyListeners();
  }

  DateTime _calculateValidUntil(PassType type) {
    final now = DateTime.now();
    switch (type) {
      case PassType.monthly:
        return DateTime(now.year, now.month + 1, now.day);
      case PassType.quarterly:
        return DateTime(now.year, now.month + 3, now.day);
      case PassType.annual:
        return DateTime(now.year + 1, now.month, now.day);
      case PassType.custom:
        return DateTime(now.year, now.month + 1, now.day); // Default to 1 month
    }
  }

  double _calculatePassFare(PassType type, PassCategory category) {
    double basePrice = 0.0;
    
    switch (type) {
      case PassType.monthly:
        basePrice = 500.0;
        break;
      case PassType.quarterly:
        basePrice = 1275.0;
        break;
      case PassType.annual:
        basePrice = 4500.0;
        break;
      case PassType.custom:
        basePrice = 500.0;
        break;
    }
    
    double discount = 0.0;
    switch (category) {
      case PassCategory.general:
        discount = 0.0;
        break;
      case PassCategory.student:
        discount = 0.5; // 50% discount
        break;
      case PassCategory.senior:
        discount = 0.3; // 30% discount
        break;
      case PassCategory.employee:
        discount = 0.2; // 20% discount
        break;
    }
    
    return basePrice * (1 - discount);
  }

  void clearGeneratedPass() {
    _generatedPass = null;
    notifyListeners();
  }

  Future<void> loadPassesFromFirestore() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final passesData = await FirebaseDatabaseService.getUserPasses(user.uid);
        
        // Convert Firestore data to BusPass objects
        _passes = passesData.map((data) {
          return BusPass(
            id: data['id'] as String,
            holderName: data['fullName'] as String? ?? '',
            holderPhoto: 'assets/images/default_avatar.png',
            type: PassType.values.firstWhere(
              (e) => e.name == data['passType'],
              orElse: () => PassType.monthly,
            ),
            category: PassCategory.general, // Default value as category is not stored in Firestore
            status: PassStatus.values.firstWhere(
              (e) => e.name == data['status'],
              orElse: () => PassStatus.active,
            ),
            applicationDate: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
            approvalDate: DateTime.now(), // Default value as approvalDate is not stored in Firestore
            validFrom: (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
            validUntil: (data['endDate'] as Timestamp?)?.toDate() ?? DateTime.now().add(Duration(days: 30)),
            fare: (data['amount'] as num?)?.toDouble() ?? 0.0,
            qrCode: data['qrCode'] as String? ?? '',
            validRoutes: ['All Routes'], // Default value as validRoutes is not stored in Firestore
            studentId: '', // Default value as studentId is not stored in Firestore
            employeeId: '', // Default value as employeeId is not stored in Firestore
            address: data['address'] as String? ?? '',
          );
        }).toList();
        
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading passes from Firestore: $e');
    }
  }

  void subscribeToPasses() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _passesSubscription?.cancel();
      _passesSubscription = FirebaseDatabaseService.getUserPassesStream(user.uid).listen((passesData) {
        // Convert Firestore data to BusPass objects
        _passes = passesData.map((data) {
          return BusPass(
            id: data['id'] as String,
            holderName: data['fullName'] as String? ?? '',
            holderPhoto: 'assets/images/default_avatar.png',
            type: PassType.values.firstWhere(
              (e) => e.name == data['passType'],
              orElse: () => PassType.monthly,
            ),
            category: PassCategory.general, // Default value as category is not stored in Firestore
            status: PassStatus.values.firstWhere(
              (e) => e.name == data['status'],
              orElse: () => PassStatus.active,
            ),
            applicationDate: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
            approvalDate: DateTime.now(), // Default value as approvalDate is not stored in Firestore
            validFrom: (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
            validUntil: (data['endDate'] as Timestamp?)?.toDate() ?? DateTime.now().add(Duration(days: 30)),
            fare: (data['amount'] as num?)?.toDouble() ?? 0.0,
            qrCode: data['qrCode'] as String? ?? '',
            validRoutes: ['All Routes'], // Default value as validRoutes is not stored in Firestore
            studentId: '', // Default value as studentId is not stored in Firestore
            employeeId: '', // Default value as employeeId is not stored in Firestore
            address: data['address'] as String? ?? '',
          );
        }).toList();
        
        notifyListeners();
      });
    }
  }

  void unsubscribeFromPasses() {
    _passesSubscription?.cancel();
    _passesSubscription = null;
  }

  List<BusPass> getActivePasses() {
    return _passes.where((pass) => pass.status == PassStatus.active).toList();
  }

  List<BusPass> getExpiredPasses() {
    return _passes.where((pass) => pass.status == PassStatus.expired).toList();
  }

  List<PassApplication> getPendingApplications() {
    return _applications.where((app) => app.status == PassStatus.pending).toList();
  }

  List<PassApplication> getApprovedApplications() {
    return _applications.where((app) => app.status == PassStatus.approved).toList();
  }

  void renewPass(String passId) {
    final passIndex = _passes.indexWhere((pass) => pass.id == passId);
    if (passIndex != -1) {
      final oldPass = _passes[passIndex];
      final renewedPass = BusPass(
        id: 'PASS${DateTime.now().millisecondsSinceEpoch}',
        holderName: oldPass.holderName,
        holderPhoto: oldPass.holderPhoto,
        type: oldPass.type,
        category: oldPass.category,
        status: PassStatus.active,
        applicationDate: DateTime.now(),
        approvalDate: DateTime.now(),
        validFrom: DateTime.now(),
        validUntil: _calculateValidUntil(oldPass.type),
        fare: oldPass.fare,
        qrCode: 'ORBIT_PASS_${DateTime.now().millisecondsSinceEpoch}',
        validRoutes: oldPass.validRoutes,
        studentId: oldPass.studentId,
        employeeId: oldPass.employeeId,
        address: oldPass.address,
      );
      
      _passes.add(renewedPass);
      notifyListeners();
    }
  }

  void expirePass(String passId) {
    final passIndex = _passes.indexWhere((pass) => pass.id == passId);
    if (passIndex != -1) {
      final pass = _passes[passIndex];
      _passes[passIndex] = BusPass(
        id: pass.id,
        holderName: pass.holderName,
        holderPhoto: pass.holderPhoto,
        type: pass.type,
        category: pass.category,
        status: PassStatus.expired,
        applicationDate: pass.applicationDate,
        approvalDate: pass.approvalDate,
        validFrom: pass.validFrom,
        validUntil: pass.validUntil,
        fare: pass.fare,
        qrCode: pass.qrCode,
        validRoutes: pass.validRoutes,
        studentId: pass.studentId,
        employeeId: pass.employeeId,
        address: pass.address,
      );
      notifyListeners();
    }
  }

  @override
  void dispose() {
    unsubscribeFromPasses();
    super.dispose();
  }
}