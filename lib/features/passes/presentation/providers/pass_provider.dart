import 'package:flutter/material.dart';
import '../../domain/pass_models.dart';

class PassProvider with ChangeNotifier {
  List<BusPass> _passes = [];
  List<PassApplication> _applications = [];
  bool _isProcessingApplication = false;
  BusPass? _generatedPass;

  List<BusPass> get passes => _passes;
  List<PassApplication> get applications => _applications;
  bool get isProcessingApplication => _isProcessingApplication;
  BusPass? get generatedPass => _generatedPass;

  Future<void> submitApplication(PassApplication application) async {
    _isProcessingApplication = true;
    _generatedPass = null;
    notifyListeners();

    // Add application to list
    _applications.add(application);

    // Simulate processing time (3 seconds as requested)
    await Future.delayed(const Duration(seconds: 3));

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
    final pass = BusPass(
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
      fare: _calculatePassFare(application.passType, application.category),
      qrCode: 'ORBIT_PASS_${DateTime.now().millisecondsSinceEpoch}',
      validRoutes: ['All Routes'], // For simplicity, all routes are valid
      studentId: application.studentId,
      employeeId: application.employeeId,
      address: application.address,
    );

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
}