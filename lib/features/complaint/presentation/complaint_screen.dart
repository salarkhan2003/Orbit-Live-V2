import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/localization_service.dart';
import '../../auth/domain/user_role.dart';

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
                ),
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: _busNumberController,
                decoration: InputDecoration(
                  hintText: 'Enter bus number (e.g., KA-01-AB-1234)',
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
                  // Simple validation for bus number format
                  if (!RegExp(r'^[A-Z0-9]{2}-[0-9]{2}-[A-Z]{1,2}-[0-9]{4}$').hasMatch(value)) {
                    return 'Please enter a valid bus number format (e.g., KA-01-AB-1234)';
                  }
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
                ),
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: _sourceController,
                decoration: InputDecoration(
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
                ),
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: _destinationController,
                decoration: InputDecoration(
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
                ),
              ),
              SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 15,
                  ),
                ),
                hint: Text('Choose a category'),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category['value'],
                    child: Text(category['label']!),
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
                ),
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: InputDecoration(
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
      // In a real app, you would send this data to your backend
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Complaint submitted successfully!'),
          backgroundColor: widget.userRole == UserRole.passenger ? Colors.blue : Colors.green,
        ),
      );
      
      // Clear the form
      setState(() {
        _selectedCategory = null;
        _descriptionController.clear();
        _busNumberController.clear();
        _sourceController.clear();
        _destinationController.clear();
      });
      
      // Navigate back after a short delay
      Future.delayed(Duration(seconds: 2), () {
        Navigator.pop(context);
      });
    }
  }
}