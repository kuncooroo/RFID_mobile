import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../shared/design_system/spacing.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../state/checkout_state.dart';

class AddCardForm extends StatefulWidget {
  const AddCardForm({
    super.key,
    required this.onSubmit,
    this.isLoading = false,
  });

  final Future<void> Function(NewCardInput input) onSubmit;
  final bool isLoading;

  @override
  State<AddCardForm> createState() => AddCardFormState();
}

class AddCardFormState extends State<AddCardForm> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _holderController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  @override
  void dispose() {
    _cardNumberController.dispose();
    _holderController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;

    final expiry = _expiryController.text.trim();
    final parts = expiry.split('/');
    if (parts.length != 2) return;

    final month = int.tryParse(parts[0].trim());
    var year = int.tryParse(parts[1].trim());
    if (month == null || year == null) return;
    if (year < 100) year += 2000;

    await widget.onSubmit(
      NewCardInput(
        cardNumber: _cardNumberController.text,
        holderName: _holderController.text.trim(),
        expiryMonth: month,
        expiryYear: year,
        cvv: _cvvController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            controller: _cardNumberController,
            label: 'Card Number',
            hintText: '1234 5678 9012 3456',
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(16),
              _CardNumberFormatter(),
            ],
            validator: (value) {
              final digits = value?.replaceAll(RegExp(r'\D'), '') ?? '';
              if (digits.length < 13) return 'Enter a valid card number';
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            controller: _holderController,
            label: 'Card Holder Name',
            hintText: 'Name on card',
            textCapitalization: TextCapitalization.words,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Enter card holder name';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: _expiryController,
                  label: 'Expiry Date',
                  hintText: 'MM/YY',
                  keyboardType: TextInputType.datetime,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                    _ExpiryDateFormatter(),
                  ],
                  validator: (value) {
                    if (value == null || !RegExp(r'^\d{2}/\d{2}$').hasMatch(value)) {
                      return 'MM/YY';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: AppTextField(
                  controller: _cvvController,
                  label: 'CVV',
                  hintText: '123',
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  validator: (value) {
                    if (value == null || value.length < 3) {
                      return 'Enter CVV';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i == 2) buffer.write('/');
      buffer.write(digits[i]);
    }
    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
