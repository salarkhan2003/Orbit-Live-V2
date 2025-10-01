import 'package:flutter/material.dart';
import '../../../../shared/orbit_live_colors.dart';
import '../../../../shared/orbit_live_text_styles.dart';
import '../../domain/ticket_models.dart';

class PaymentMethodSelector extends StatefulWidget {
  final PaymentMethod? selectedMethod;
  final Function(PaymentMethod) onMethodSelected;
  final Function(PaymentDetails) onPaymentDetailsChanged;
  final double amount;

  const PaymentMethodSelector({
    super.key,
    required this.selectedMethod,
    required this.onMethodSelected,
    required this.onPaymentDetailsChanged,
    required this.amount,
  });

  @override
  State<PaymentMethodSelector> createState() => _PaymentMethodSelectorState();
}

class _PaymentMethodSelectorState extends State<PaymentMethodSelector> {
  final _upiController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Add listeners to update payment details when amount changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updatePaymentDetails();
    });
  }

  @override
  void didUpdateWidget(covariant PaymentMethodSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update payment details when amount changes
    if (oldWidget.amount != widget.amount && widget.selectedMethod != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updatePaymentDetails();
      });
    }
  }

  @override
  void dispose() {
    _upiController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Payment methods
        _buildPaymentMethodCard(
          method: PaymentMethod.upi,
          title: 'UPI Payment',
          subtitle: 'Pay using UPI ID or QR code',
          icon: Icons.account_balance_wallet,
          color: Colors.purple,
        ),
        
        _buildPaymentMethodCard(
          method: PaymentMethod.wallet,
          title: 'Digital Wallet',
          subtitle: 'Pay using digital wallet balance',
          icon: Icons.wallet,
          color: Colors.orange,
        ),
        
        _buildPaymentMethodCard(
          method: PaymentMethod.debitCard,
          title: 'Debit Card',
          subtitle: 'Pay using your debit card',
          icon: Icons.credit_card,
          color: Colors.blue,
        ),
        
        _buildPaymentMethodCard(
          method: PaymentMethod.creditCard,
          title: 'Credit Card',
          subtitle: 'Pay using your credit card',
          icon: Icons.credit_card,
          color: Colors.green,
        ),
        
        const SizedBox(height: 24),
        
        // Payment details form
        if (widget.selectedMethod != null)
          _buildPaymentDetailsForm(),
        
        const SizedBox(height: 24),
        
        // Amount summary
        _buildAmountSummary(),
      ],
    );
  }

  Widget _buildPaymentMethodCard({
    required PaymentMethod method,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = widget.selectedMethod == method;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? OrbitLiveColors.primaryTeal : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          widget.onMethodSelected(method);
          _updatePaymentDetails();
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
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
                      subtitle,
                      style: OrbitLiveTextStyles.bodyMedium.copyWith(
                        color: OrbitLiveColors.mediumGray,
                      ),
                    ),
                  ],
                ),
              ),
              Radio<PaymentMethod>(
                value: method,
                groupValue: widget.selectedMethod,
                onChanged: (value) {
                  if (value != null) {
                    widget.onMethodSelected(value);
                    _updatePaymentDetails();
                  }
                },
                activeColor: OrbitLiveColors.primaryTeal,
                toggleable: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentDetailsForm() {
    switch (widget.selectedMethod!) {
      case PaymentMethod.upi:
        return _buildUPIForm();
      case PaymentMethod.wallet:
        return _buildWalletForm();
      case PaymentMethod.debitCard:
      case PaymentMethod.creditCard:
        return _buildCardForm();
    }
  }

  Widget _buildUPIForm() {
    return Container(
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
            'UPI Payment Details',
            style: OrbitLiveTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _upiController,
            onChanged: (_) => _updatePaymentDetails(),
            decoration: InputDecoration(
              labelText: 'UPI ID',
              hintText: 'example@upi',
              prefixIcon: const Icon(Icons.account_balance_wallet),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletForm() {
    return Container(
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
            'Digital Wallet',
            style: OrbitLiveTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.wallet, color: Colors.green),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Wallet Balance',
                      style: OrbitLiveTextStyles.bodyMedium.copyWith(
                        color: Colors.green.shade700,
                      ),
                    ),
                    Text(
                      '₹1,250.00',
                      style: OrbitLiveTextStyles.bodyLarge.copyWith(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardForm() {
    return Container(
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
            '${widget.selectedMethod == PaymentMethod.debitCard ? 'Debit' : 'Credit'} Card Details',
            style: OrbitLiveTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
          // Card number
          TextField(
            controller: _cardNumberController,
            onChanged: (_) => _updatePaymentDetails(),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Card Number',
              hintText: '1234 5678 9012 3456',
              prefixIcon: const Icon(Icons.credit_card),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Cardholder name
          TextField(
            controller: _nameController,
            onChanged: (_) => _updatePaymentDetails(),
            decoration: InputDecoration(
              labelText: 'Cardholder Name',
              hintText: 'John Doe',
              prefixIcon: const Icon(Icons.person),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Expiry and CVV
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _expiryController,
                  onChanged: (_) => _updatePaymentDetails(),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'MM/YY',
                    hintText: '12/25',
                    prefixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _cvvController,
                  onChanged: (_) => _updatePaymentDetails(),
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'CVV',
                    hintText: '123',
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmountSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            OrbitLiveColors.primaryTeal.withValues(alpha: 0.1),
            OrbitLiveColors.primaryBlue.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: OrbitLiveColors.primaryTeal.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total Amount',
            style: OrbitLiveTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            '₹${widget.amount.toStringAsFixed(2)}',
            style: OrbitLiveTextStyles.cardTitle.copyWith(
              color: OrbitLiveColors.primaryTeal,
              fontSize: 24,
            ),
          ),
        ],
      ),
    );
  }

  void _updatePaymentDetails() {
    if (widget.selectedMethod == null) return;
    
    PaymentDetails details;
    
    switch (widget.selectedMethod!) {
      case PaymentMethod.upi:
        details = PaymentDetails(
          method: PaymentMethod.upi,
          upiId: _upiController.text,
          amount: widget.amount,
        );
        break;
      case PaymentMethod.wallet:
        details = PaymentDetails(
          method: PaymentMethod.wallet,
          walletId: 'wallet_123',
          amount: widget.amount,
        );
        break;
      case PaymentMethod.debitCard:
      case PaymentMethod.creditCard:
        details = PaymentDetails(
          method: widget.selectedMethod!,
          cardNumber: _cardNumberController.text,
          amount: widget.amount,
        );
        break;
    }
    
    widget.onPaymentDetailsChanged(details);
  }
}