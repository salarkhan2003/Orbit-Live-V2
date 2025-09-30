import 'package:flutter/material.dart';
import '../../auth/domain/user_role.dart';
import '../../../core/localization_service.dart';

class ComplaintScreen extends StatefulWidget {
  final UserRole userRole;

  const ComplaintScreen({Key? key, required this.userRole}) : super(key: key);

  @override
  _ComplaintScreenState createState() => _ComplaintScreenState();
}

class _ComplaintScreenState extends State<ComplaintScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedCategory;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _busNumberController = TextEditingController();
  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();

  // Complaint categories based on user role
  List<Map<String, String>> get _categories {
    if (widget.userRole == UserRole.passenger) {
      return [
        {'value': 'bus_overcrowded', 'label': 'Bus Overcrowded'},
        {'value': 'request_new_bus', 'label': 'Request New Bus'},
        {'value': 'bus_delay', 'label': 'Bus Delay'},
        {'value': 'rude_staff', 'label': 'Rude Staff'},
        {'value': 'cleanliness', 'label': 'Cleanliness'},
        {'value': 'ticket_issue', 'label': 'Ticket Issue'},
        {'value': 'others', 'label': 'Others'},
      ];
    } else {
      return [
        {'value': 'maintenance', 'label': 'Maintenance'},
        {'value': 'route_issue', 'label': 'Route Issue'},
        {'value': 'passenger_misconduct', 'label': 'Passenger Misconduct'},
        {'value': 'others', 'label': 'Others'},
      ];
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _busNumberController.dispose();
    _sourceController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.translate('raise_complaint')),
        backgroundColor: widget.userRole == UserRole.passenger ? Colors.blue : Colors.green,
        foregroundColor: Colors.white, // Ensure title is visible
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                widget.userRole == UserRole.passenger 
                  ? 'Passenger Complaint' 
                  : 'Conductor Complaint',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: widget.userRole == UserRole.passenger ? Colors.blue : Colors.green,
                ),
              ),
              SizedBox(height: 30),
              // Bus Number Field
              Text(
                'Bus Number',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black, // Ensure visibility
                ),
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: _busNumberController,
                decoration: InputDecoration(
                  labelText: 'Bus Number',
                  hintText: 'Enter bus number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 15,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter bus number';
                  }
                  // Allow any format for bus number - no restrictions
                  return null;
                },
              ),
              SizedBox(height: 25),
              // Source Field
              Text(
                'Source',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black, // Ensure visibility
                ),
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: _sourceController,
                decoration: InputDecoration(
                  labelText: 'Source',
                  hintText: 'Enter source location',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 15,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter source location';
                  }
                  return null;
                },
              ),
              SizedBox(height: 25),
              // Destination Field
              Text(
                'Destination',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black, // Ensure visibility
                ),
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: _destinationController,
                decoration: InputDecoration(
                  labelText: 'Destination',
                  hintText: 'Enter destination location',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 15,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter destination location';
                  }
                  return null;
                },
              ),
              SizedBox(height: 25),
              Text(
                'Select Category',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black, // Ensure visibility
                ),
              ),
              SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 15,
                  ),
                ),
                hint: Text(
                  'Choose a category',
                  style: TextStyle(
                    color: Colors.grey, // Ensure visibility
                  ),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category['value'],
                    child: Text(
                      category['label']!,
                      style: TextStyle(
                        color: Colors.black, // Ensure visibility
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),
              SizedBox(height: 25),
              Text(
                'Description',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black, // Ensure visibility
                ),
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: 'Describe your complaint in detail...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: EdgeInsets.all(15),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please provide a description';
                  }
                  if (value.length < 10) {
                    return 'Description should be at least 10 characters';
                  }
                  return null;
                },
              ),
              SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitComplaint,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: widget.userRole == UserRole.passenger ? Colors.blue : Colors.green,
                    foregroundColor: Colors.white, // Ensure text is visible
                  ),
                  child: Text(
                    'Submit Complaint',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitComplaint() {
    if (_formKey.currentState!.validate()) {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    widget.userRole == UserRole.passenger ? Colors.blue : Colors.green,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Submitting your complaint...',
                  style: TextStyle(
                    color: Colors.black, // Ensure visibility
                  ),
                ),
              ],
            ),
          );
        },
      );

      // Simulate API call delay
      Future.delayed(Duration(seconds: 2), () {
        Navigator.pop(context); // Close loading dialog
        
        // Generate complaint ID
        String complaintId = 'CMP${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
        
        // Show success dialog with complaint details
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 32,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Success!',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your complaint has been successfully submitted and registered with our system.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black, // Ensure visibility
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Complaint Details:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black, // Ensure visibility
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'ID: $complaintId',
                          style: TextStyle(
                            color: Colors.black, // Ensure visibility
                          ),
                        ),
                        Text(
                          'Bus: ${_busNumberController.text}',
                          style: TextStyle(
                            color: Colors.black, // Ensure visibility
                          ),
                        ),
                        Text(
                          'Route: ${_sourceController.text} → ${_destinationController.text}',
                          style: TextStyle(
                            color: Colors.black, // Ensure visibility
                          ),
                        ),
                        Text(
                          'Category: ${_categories.firstWhere((cat) => cat['value'] == _selectedCategory)['label']}',
                          style: TextStyle(
                            color: Colors.black, // Ensure visibility
                          ),
                        ),
                        Text(
                          'Status: Under Review',
                          style: TextStyle(
                            color: Colors.black, // Ensure visibility
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'We will investigate your complaint and get back to you within 24-48 hours. You can track the status using the complaint ID.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close success dialog
                    
                    // Clear the form
                    setState(() {
                      _selectedCategory = null;
                      _descriptionController.clear();
                      _busNumberController.clear();
                      _sourceController.clear();
                      _destinationController.clear();
                    });
                    
                    // Navigate back to previous screen
                    Navigator.pop(context);
                  },
                  child: Text(
                    'OK',
                    style: TextStyle(
                      color: widget.userRole == UserRole.passenger ? Colors.blue : Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      });
    }
  }
}