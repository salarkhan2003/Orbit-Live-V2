import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/orbit_live_colors.dart';
import '../../../shared/orbit_live_text_styles.dart';
import '../../../shared/components/app_header.dart';
import '../domain/pass_models.dart';
import 'widgets/animated_pass_card.dart';
import 'providers/pass_provider.dart';
import '../../payments/presentation/payment_options_screen.dart';

class PassApplicationScreen extends StatefulWidget {
  const PassApplicationScreen({super.key});

  @override
  State<PassApplicationScreen> createState() => _PassApplicationScreenState();
}

class _PassApplicationScreenState extends State<PassApplicationScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // Add form key
  int _currentStep = 0;
  bool _isSubmitting = false; // Add isSubmitting variable
  
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
            
            // Pass type cards with enhanced styling
            _buildPassTypeCards(),
            
            const SizedBox(height: 30),
            
            // Continue button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _selectedPassType != null ? () => _nextStep() : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: OrbitLiveColors.primaryTeal,
                  foregroundColor: Colors.white,
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  disabledBackgroundColor: Colors.grey.shade300,
                  disabledForegroundColor: Colors.grey.shade500,
                ),
                child: Text(
                  'Continue',
                  style: OrbitLiveTextStyles.buttonPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPassTypeCards() {
    final passTypes = [
      {
        'type': PassType.monthly,
        'title': 'Monthly Pass',
        'description': 'Valid for 30 days',
        'price': '₹300',
        'icon': Icons.calendar_today,
        'color': Colors.blue,
      },
      {
        'type': PassType.quarterly,
        'title': 'Quarterly Pass',
        'description': 'Valid for 3 months',
        'price': '₹800',
        'icon': Icons.calendar_view_month,
        'color': Colors.green,
      },
      {
        'type': PassType.annual,
        'title': 'Annual Pass',
        'description': 'Valid for 12 months',
        'price': '₹3000',
        'icon': Icons.calendar_month,
        'color': Colors.purple,
      },
    ];
    
    return Column(
      children: passTypes.map((passType) {
        final isSelected = _selectedPassType == passType['type'];
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [
                      passType['color'] as Color,
                      (passType['color'] as Color).withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : LinearGradient(
                    colors: [Colors.white, Colors.grey.shade50],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: isSelected
                ? Border.all(color: passType['color'] as Color, width: 2)
                : null,
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(15),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected 
                    ? Colors.white.withValues(alpha: 0.2) 
                    : (passType['color'] as Color).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                passType['icon'] as IconData,
                color: isSelected ? Colors.white : passType['color'] as Color,
              ),
            ),
            title: Text(
              passType['title'] as String,
              style: OrbitLiveTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : OrbitLiveColors.black,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  passType['description'] as String,
                  style: OrbitLiveTextStyles.bodyMedium.copyWith(
                    color: isSelected ? Colors.white70 : OrbitLiveColors.darkGray,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  passType['price'] as String,
                  style: OrbitLiveTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : passType['color'] as Color,
                  ),
                ),
              ],
            ),
            trailing: isSelected
                ? const Icon(Icons.check_circle, color: Colors.white)
                : null,
            onTap: () {
              setState(() {
                _selectedPassType = passType['type'] as PassType;
              });
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildUserDetailsStep() {
    return SlideTransition(
      position: _slideAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey, // Add form key
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'User Details',
                style: OrbitLiveTextStyles.cardTitle.copyWith(
                  fontSize: 24,
                  color: OrbitLiveColors.black,
                ),
              ),
              const SizedBox(height: 24),
              
              // Name field
              _buildEnhancedTextField(
                controller: _nameController,
                label: 'Full Name',
                hint: 'Enter your full name',
                icon: Icons.person,
              ),
              
              const SizedBox(height: 20),
              
              // Email field
              _buildEnhancedTextField(
                controller: _emailController,
                label: 'Email Address',
                hint: 'Enter your email address',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
              ),
              
              const SizedBox(height: 20),
              
              // Phone field
              _buildEnhancedTextField(
                controller: _phoneController,
                label: 'Phone Number',
                hint: 'Enter your phone number',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              
              const SizedBox(height: 20),
              
              // Address field
              _buildEnhancedTextField(
                controller: _addressController,
                label: 'Address',
                hint: 'Enter your address',
                icon: Icons.home,
                maxLines: 3,
              ),
              
              const SizedBox(height: 20),
              
              // Category selection
              Text(
                'Select Category',
                style: OrbitLiveTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: OrbitLiveColors.black,
                ),
              ),
              const SizedBox(height: 16),
              
              _buildCategoryCards(),
              
              const SizedBox(height: 30),
              
              // Continue button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _nameController.text.isNotEmpty &&
                           _emailController.text.isNotEmpty &&
                           _phoneController.text.isNotEmpty &&
                           _addressController.text.isNotEmpty &&
                           _selectedCategory != null
                      ? () => _nextStep()
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: OrbitLiveColors.primaryTeal,
                    foregroundColor: Colors.white,
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    disabledBackgroundColor: Colors.grey.shade300,
                    disabledForegroundColor: Colors.grey.shade500,
                  ),
                  child: Text(
                    'Continue',
                    style: OrbitLiveTextStyles.buttonPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        onChanged: (_) {
          // Trigger state update to enable/disable continue button
          setState(() {});
        },
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: OrbitLiveColors.primaryTeal),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
          labelStyle: TextStyle(
            color: OrbitLiveColors.black,
            fontWeight: FontWeight.w500,
          ),
          hintStyle: TextStyle(
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCards() {
    final categories = [
      {
        'category': PassCategory.general,
        'title': 'General',
        'description': 'For all general passengers',
        'icon': Icons.person,
        'color': Colors.blue,
      },
      {
        'category': PassCategory.student,
        'title': 'Student',
        'description': 'For students with valid ID',
        'icon': Icons.school,
        'color': Colors.green,
      },
      {
        'category': PassCategory.senior,
        'title': 'Senior Citizen',
        'description': 'For passengers above 60 years',
        'icon': Icons.accessible,
        'color': Colors.purple,
      },
      {
        'category': PassCategory.employee,
        'title': 'Employee',
        'description': 'For government/private employees',
        'icon': Icons.work,
        'color': Colors.orange,
      },
    ];
    
    return Column(
      children: categories.map((category) {
        final isSelected = _selectedCategory == category['category'];
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [
                      category['color'] as Color,
                      (category['color'] as Color).withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : LinearGradient(
                    colors: [Colors.white, Colors.grey.shade50],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: isSelected
                ? Border.all(color: category['color'] as Color, width: 2)
                : null,
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(15),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected 
                    ? Colors.white.withValues(alpha: 0.2) 
                    : (category['color'] as Color).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                category['icon'] as IconData,
                color: isSelected ? Colors.white : category['color'] as Color,
              ),
            ),
            title: Text(
              category['title'] as String,
              style: OrbitLiveTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : OrbitLiveColors.black,
              ),
            ),
            subtitle: Text(
              category['description'] as String,
              style: OrbitLiveTextStyles.bodyMedium.copyWith(
                color: isSelected ? Colors.white70 : OrbitLiveColors.darkGray,
              ),
            ),
            trailing: isSelected
                ? const Icon(Icons.check_circle, color: Colors.white)
                : null,
            onTap: () {
              setState(() {
                _selectedCategory = category['category'] as PassCategory;
                
                // Clear category-specific fields when changing category
                _studentIdController.clear();
                _employeeIdController.clear();
              });
            },
          ),
        );
      }).toList(),
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
                  color: Colors.black.withValues(alpha: 0.05),
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
                color: Colors.red.withValues(alpha: 0.1),
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
                  color: Colors.green.withValues(alpha: 0.3),
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
                  color: Colors.black.withValues(alpha: 0.05),
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

  void _nextStep() {
    setState(() {
      _currentStep++;
    });
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _previousStep() {
    setState(() {
      _currentStep--;
    });
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
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
    if (!_formKey.currentState!.validate()) return;

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
      studentId: _studentIdController.text,
      employeeId: _employeeIdController.text,
    );

    setState(() {
      _isSubmitting = true;
    });

    try {
      // For pass applications, we'll use a fixed distance since it's not route-specific
      final distanceInKm = 0.0;
      
      // Show payment options screen
      final result = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PaymentOptionsScreen(
            distanceInKm: distanceInKm,
            source: 'Pass Application',
            destination: '${_selectedPassType?.name} pass for ${_selectedCategory?.name}',
            onPaymentSuccess: () {
              // This will be called when payment is successful
            },
          ),
        ),
      );

      // If payment was successful, submit the application
      if (result == true) {
        await passProvider.submitApplicationWithPayment(application);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pass application submitted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Navigate back to all passes screen
          Navigator.pushReplacementNamed(context, '/all-passes');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting application: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}