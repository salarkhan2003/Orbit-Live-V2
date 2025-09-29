import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/orbit_live_colors.dart';
import '../../../shared/orbit_live_text_styles.dart';
import '../../../shared/components/app_header.dart';
import '../../../shared/utils/responsive_helper.dart';
import '../domain/pass_models.dart';
import 'widgets/animated_pass_card.dart';
import 'providers/pass_provider.dart';

class PassApplicationScreen extends StatefulWidget {
  const PassApplicationScreen({super.key});

  @override
  State<PassApplicationScreen> createState() => _PassApplicationScreenState();
}

class _PassApplicationScreenState extends State<PassApplicationScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  
  // Form controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _employeeIdController = TextEditingController();
  
  // Selected values
  PassType? _selectedPassType;
  PassCategory? _selectedCategory;
  List<String> _uploadedDocuments = [];
  
  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack));
    
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _studentIdController.dispose();
    _employeeIdController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: OrbitLiveColors.backgroundGradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildStepIndicator(),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentStep = index;
                    });
                  },
                  children: [
                    _buildPassTypeStep(),
                    _buildUserDetailsStep(),
                    _buildDocumentsStep(),
                    _buildReviewStep(),
                  ],
                ),
              ),
              _buildNavigationButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: const AppHeader(
        title: 'Apply for Pass',
        subtitle: 'Get your monthly, quarterly or annual pass',
        showBackButton: true,
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: List.generate(4, (index) {
          final isActive = index <= _currentStep;
          final isCompleted = index < _currentStep;
          
          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive ? OrbitLiveColors.primaryTeal : Colors.grey.shade300,
                    border: Border.all(
                      color: isActive ? OrbitLiveColors.primaryTeal : Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isActive ? Colors.white : Colors.grey.shade600,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                if (index < 3)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: isCompleted ? OrbitLiveColors.primaryTeal : Colors.grey.shade300,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPassTypeStep() {
    return SlideTransition(
      position: _slideAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Pass Type',
              style: OrbitLiveTextStyles.cardTitle.copyWith(
                fontSize: 24,
                color: OrbitLiveColors.black,
              ),
            ),
            const SizedBox(height: 24),
            
            _buildPassTypeCard(
              type: PassType.monthly,
              title: 'Monthly Pass',
              description: '30 days unlimited travel',
              price: 500.0,
              icon: Icons.calendar_view_month,
              color: Colors.blue,
            ),
            
            _buildPassTypeCard(
              type: PassType.quarterly,
              title: 'Quarterly Pass',
              description: '90 days with 15% discount',
              price: 1275.0,
              originalPrice: 1500.0,
              icon: Icons.calendar_view_week,
              color: Colors.orange,
            ),
            
            _buildPassTypeCard(
              type: PassType.annual,
              title: 'Annual Pass',
              description: '365 days with 25% discount',
              price: 4500.0,
              originalPrice: 6000.0,
              icon: Icons.calendar_today,
              color: Colors.green,
            ),
            
            const SizedBox(height: 24),
            
            if (_selectedPassType != null) ...[
              Text(
                'Select Category',
                style: OrbitLiveTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: OrbitLiveColors.black,
                ),
              ),
              const SizedBox(height: 16),
              
              _buildCategoryCard(
                category: PassCategory.general,
                title: 'General',
                description: 'Standard pricing',
                discount: 0,
              ),
              
              _buildCategoryCard(
                category: PassCategory.student,
                title: 'Student',
                description: 'Valid student ID required',
                discount: 50,
              ),
              
              _buildCategoryCard(
                category: PassCategory.senior,
                title: 'Senior Citizen',
                description: 'Age 60+ with valid ID',
                discount: 30,
              ),
              
              _buildCategoryCard(
                category: PassCategory.employee,
                title: 'Employee',
                description: 'Company employee ID required',
                discount: 20,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPassTypeCard({
    required PassType type,
    required String title,
    required String description,
    required double price,
    double? originalPrice,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _selectedPassType == type;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? OrbitLiveColors.primaryTeal : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedPassType = type;
            _selectedCategory = null; // Reset category when pass type changes
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: OrbitLiveTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: OrbitLiveTextStyles.bodyMedium.copyWith(
                        color: OrbitLiveColors.mediumGray,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (originalPrice != null) ...[
                    Text(
                      '₹${originalPrice.toStringAsFixed(0)}',
                      style: OrbitLiveTextStyles.bodyMedium.copyWith(
                        color: OrbitLiveColors.mediumGray,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    const SizedBox(height: 2),
                  ],
                  Text(
                    '₹${price.toStringAsFixed(0)}',
                    style: OrbitLiveTextStyles.bodyLarge.copyWith(
                      color: OrbitLiveColors.primaryTeal,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard({
    required PassCategory category,
    required String title,
    required String description,
    required int discount,
  }) {
    final isSelected = _selectedCategory == category;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? OrbitLiveColors.primaryTeal : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedCategory = category;
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: OrbitLiveTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (discount > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${discount}% OFF',
                              style: OrbitLiveTextStyles.bodySmall.copyWith(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: OrbitLiveTextStyles.bodySmall.copyWith(
                        color: OrbitLiveColors.mediumGray,
                      ),
                    ),
                  ],
                ),
              ),
              Radio<PassCategory>(
                value: category,
                groupValue: _selectedCategory,
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                activeColor: OrbitLiveColors.primaryTeal,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserDetailsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personal Details',
            style: OrbitLiveTextStyles.cardTitle.copyWith(
              fontSize: 24,
              color: OrbitLiveColors.black,
            ),
          ),
          const SizedBox(height: 24),
          
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  hint: 'Enter your full name',
                  icon: Icons.person,
                ),
                
                const SizedBox(height: 16),
                
                _buildTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  hint: 'Enter your email',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                ),
                
                const SizedBox(height: 16),
                
                _buildTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  hint: 'Enter your phone number',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                ),
                
                const SizedBox(height: 16),
                
                _buildTextField(
                  controller: _addressController,
                  label: 'Address',
                  hint: 'Enter your complete address',
                  icon: Icons.location_on,
                  maxLines: 3,
                ),
                
                if (_selectedCategory == PassCategory.student) ...[
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _studentIdController,
                    label: 'Student ID',
                    hint: 'Enter your student ID',
                    icon: Icons.school,
                  ),
                ],
                
                if (_selectedCategory == PassCategory.employee) ...[
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _employeeIdController,
                    label: 'Employee ID',
                    hint: 'Enter your employee ID',
                    icon: Icons.badge,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildDocumentsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upload Documents',
            style: OrbitLiveTextStyles.cardTitle.copyWith(
              fontSize: 24,
              color: OrbitLiveColors.black,
            ),
          ),
          const SizedBox(height: 24),
          
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Required Documents',
                  style: OrbitLiveTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                
                _buildDocumentItem('Photo ID Proof', true),
                _buildDocumentItem('Address Proof', true),
                
                if (_selectedCategory == PassCategory.student)
                  _buildDocumentItem('Student ID Card', true),
                
                if (_selectedCategory == PassCategory.employee)
                  _buildDocumentItem('Employee ID Card', true),
                
                if (_selectedCategory == PassCategory.senior)
                  _buildDocumentItem('Age Proof (60+)', true),
                
                const SizedBox(height: 24),
                
                // Upload button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _uploadDocuments,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Upload Documents'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: OrbitLiveColors.primaryTeal),
                      foregroundColor: OrbitLiveColors.primaryTeal,
                    ),
                  ),
                ),
                
                if (_uploadedDocuments.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Uploaded Documents:',
                    style: OrbitLiveTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._uploadedDocuments.map((doc) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green, size: 20),
                        const SizedBox(width: 8),
                        Text(doc, style: OrbitLiveTextStyles.bodyMedium),
                      ],
                    ),
                  )),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentItem(String title, bool required) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            required ? Icons.circle : Icons.circle_outlined,
            size: 8,
            color: OrbitLiveColors.primaryTeal,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: OrbitLiveTextStyles.bodyMedium,
            ),
          ),
          if (required)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Required',
                style: OrbitLiveTextStyles.bodySmall.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReviewStep() {
    return Consumer<PassProvider>(
      builder: (context, passProvider, child) {
        if (passProvider.isProcessingApplication) {
          return _buildProcessingApplication();
        }
        
        if (passProvider.generatedPass != null) {
          return _buildPassGenerated(passProvider.generatedPass!);
        }
        
        return _buildApplicationSummary();
      },
    );
  }

  Widget _buildProcessingApplication() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated processing indicator
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  OrbitLiveColors.primaryTeal,
                  OrbitLiveColors.primaryBlue,
                ],
              ),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 4,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Processing Application...',
            style: OrbitLiveTextStyles.cardTitle.copyWith(
              color: OrbitLiveColors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your pass will be approved in 3 seconds',
            style: OrbitLiveTextStyles.bodyMedium.copyWith(
              color: OrbitLiveColors.mediumGray,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPassGenerated(BusPass pass) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 40),
          
          // Success animation
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green,
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 40,
            ),
          ),
          
          const SizedBox(height: 24),
          
          Text(
            'Pass Approved!',
            style: OrbitLiveTextStyles.cardTitle.copyWith(
              fontSize: 28,
              color: OrbitLiveColors.black,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Your digital pass is ready to use',
            style: OrbitLiveTextStyles.bodyMedium.copyWith(
              color: OrbitLiveColors.mediumGray,
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Animated pass card
          AnimatedPassCard(pass: pass),
          
          const SizedBox(height: 40),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Download pass
                  },
                  icon: const Icon(Icons.download),
                  label: const Text('Download'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: OrbitLiveColors.primaryTeal),
                    foregroundColor: OrbitLiveColors.primaryTeal,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  icon: const Icon(Icons.home),
                  label: const Text('Home'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: OrbitLiveColors.primaryTeal,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationSummary() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Application Summary',
            style: OrbitLiveTextStyles.cardTitle.copyWith(
              fontSize: 24,
              color: OrbitLiveColors.black,
            ),
          ),
          const SizedBox(height: 24),
          
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryRow('Pass Type', _selectedPassType?.name ?? ''),
                _buildSummaryRow('Category', _selectedCategory?.name ?? ''),
                _buildSummaryRow('Name', _nameController.text),
                _buildSummaryRow('Email', _emailController.text),
                _buildSummaryRow('Phone', _phoneController.text),
                if (_selectedCategory == PassCategory.student)
                  _buildSummaryRow('Student ID', _studentIdController.text),
                if (_selectedCategory == PassCategory.employee)
                  _buildSummaryRow('Employee ID', _employeeIdController.text),
                const Divider(height: 32),
                _buildSummaryRow(
                  'Total Amount',
                  '₹${_calculatePassAmount().toStringAsFixed(2)}',
                  isTotal: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: OrbitLiveTextStyles.bodyMedium.copyWith(
              color: isTotal ? OrbitLiveColors.black : OrbitLiveColors.mediumGray,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: OrbitLiveTextStyles.bodyMedium.copyWith(
              color: isTotal ? OrbitLiveColors.primaryTeal : OrbitLiveColors.black,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _goToPreviousStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: OrbitLiveColors.primaryTeal),
                  foregroundColor: OrbitLiveColors.primaryTeal,
                ),
                child: const Text('Back'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _canProceed() ? _goToNextStep : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: OrbitLiveColors.primaryTeal,
                foregroundColor: Colors.white,
              ),
              child: Text(_getNextButtonText()),
            ),
          ),
        ],
      ),
    );
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return _selectedPassType != null && _selectedCategory != null;
      case 1:
        return _nameController.text.isNotEmpty &&
               _emailController.text.isNotEmpty &&
               _phoneController.text.isNotEmpty &&
               _addressController.text.isNotEmpty;
      case 2:
        return _uploadedDocuments.isNotEmpty;
      case 3:
        return true;
      default:
        return false;
    }
  }

  String _getNextButtonText() {
    switch (_currentStep) {
      case 0:
        return 'Continue';
      case 1:
        return 'Upload Documents';
      case 2:
        return 'Review Application';
      case 3:
        return 'Submit Application';
      default:
        return 'Next';
    }
  }

  void _goToNextStep() {
    if (_currentStep < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _submitApplication();
    }
  }

  void _goToPreviousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _uploadDocuments() {
    // Mock document upload
    setState(() {
      _uploadedDocuments = [
        'Photo ID Proof.pdf',
        'Address Proof.pdf',
        if (_selectedCategory == PassCategory.student) 'Student ID Card.pdf',
        if (_selectedCategory == PassCategory.employee) 'Employee ID Card.pdf',
        if (_selectedCategory == PassCategory.senior) 'Age Proof.pdf',
      ];
    });
  }

  double _calculatePassAmount() {
    if (_selectedPassType == null || _selectedCategory == null) return 0.0;
    
    double basePrice = 0.0;
    switch (_selectedPassType!) {
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
    switch (_selectedCategory!) {
      case PassCategory.general:
        discount = 0.0;
        break;
      case PassCategory.student:
        discount = 0.5;
        break;
      case PassCategory.senior:
        discount = 0.3;
        break;
      case PassCategory.employee:
        discount = 0.2;
        break;
    }
    
    return basePrice * (1 - discount);
  }

  Future<void> _submitApplication() async {
    final passProvider = Provider.of<PassProvider>(context, listen: false);
    
    final application = PassApplication(
      id: 'APP${DateTime.now().millisecondsSinceEpoch}',
      applicantName: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      address: _addressController.text,
      passType: _selectedPassType!,
      category: _selectedCategory!,
      applicationDate: DateTime.now(),
      status: PassStatus.pending,
      documents: _uploadedDocuments,
      studentId: _selectedCategory == PassCategory.student ? _studentIdController.text : null,
      employeeId: _selectedCategory == PassCategory.employee ? _employeeIdController.text : null,
    );
    
    await passProvider.submitApplication(application);
  }
}