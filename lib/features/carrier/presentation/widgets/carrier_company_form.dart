import 'package:flutter/material.dart';

typedef CarrierCompanyFormSubmit =
    Future<void> Function({
      required String companyName,
      required String companyEmail,
      required String phoneNumber,
      required String street,
      required String city,
      required String state,
      required String country,
      required String postalCode,
    });

class CarrierCompanyForm extends StatefulWidget {
  final bool isLoading;
  final CarrierCompanyFormSubmit onSubmit;

  const CarrierCompanyForm({
    super.key,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  State<CarrierCompanyForm> createState() => _CarrierCompanyFormState();
}

class _CarrierCompanyFormState extends State<CarrierCompanyForm> {
  final _formKey = GlobalKey<FormState>();
  final _companyNameController = TextEditingController();
  final _companyEmailController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();
  final _postalCodeController = TextEditingController();

  @override
  void dispose() {
    _companyNameController.dispose();
    _companyEmailController.dispose();
    _phoneNumberController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    await widget.onSubmit(
      companyName: _companyNameController.text.trim(),
      companyEmail: _companyEmailController.text.trim(),
      phoneNumber: _phoneNumberController.text.trim(),
      street: _streetController.text.trim(),
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      country: _countryController.text.trim(),
      postalCode: _postalCodeController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _requiredField(_companyNameController, 'Company name'),
          const SizedBox(height: 12),
          _requiredField(
            _companyEmailController,
            'Company email',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          _requiredField(
            _phoneNumberController,
            'Phone number',
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          _requiredField(_streetController, 'Street'),
          const SizedBox(height: 12),
          _requiredField(_cityController, 'City'),
          const SizedBox(height: 12),
          _requiredField(_stateController, 'State'),
          const SizedBox(height: 12),
          _requiredField(_countryController, 'Country'),
          const SizedBox(height: 12),
          _requiredField(_postalCodeController, 'Postal code'),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.isLoading ? null : _submit,
              child: widget.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }

  TextFormField _requiredField(
    TextEditingController controller,
    String label, {
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '$label is required';
        }
        return null;
      },
    );
  }
}
