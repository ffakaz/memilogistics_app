// lib/features/shipper/presentation/widgets/shipper_company_form.dart

import 'package:flutter/material.dart';

import '../../../carrier/presentation/widgets/address_form.dart';
import '../../domain/entities/shipper_company.dart';

/// Shipper Company Form Widget
///
/// Reusable form for creating/editing shipper company profiles.
/// Includes company information and address fields with validation.
class ShipperCompanyForm extends StatefulWidget {
  final Future<void> Function({
    required String firstName,
    required String lastName,
    required String companyName,
    required String businessName,
    required String phoneNumber,
    required String street,
    required String city,
    required String state,
    required String country,
    required String postalCode,
  })
  onSubmit;

  final bool isLoading;
  final ShipperCompany? initialCompany;
  final String submitLabel;

  const ShipperCompanyForm({
    super.key,
    required this.onSubmit,
    this.isLoading = false,
    this.initialCompany,
    this.submitLabel = 'Save Shipper Profile',
  });

  @override
  State<ShipperCompanyForm> createState() => _ShipperCompanyFormState();
}

class _ShipperCompanyFormState extends State<ShipperCompanyForm> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();

  // Address fields
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();
  final _postalCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final company = widget.initialCompany;
    if (company == null) return;

    _firstNameController.text = company.firstName;
    _lastNameController.text = company.lastName;
    _companyNameController.text = company.companyName;
    _businessNameController.text = company.businessName;
    _phoneNumberController.text = company.address.phoneNumber;
    _streetController.text = company.address.street;
    _cityController.text = company.address.city;
    _stateController.text = company.address.state;
    _countryController.text = company.address.country;
    _postalCodeController.text = company.address.zip;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _companyNameController.dispose();
    _businessNameController.dispose();
    _phoneNumberController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await widget.onSubmit(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      companyName: _companyNameController.text.trim(),
      businessName: _businessNameController.text.trim(),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _firstNameController,
            decoration: const InputDecoration(
              labelText: 'First Name',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'First name is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _lastNameController,
            decoration: const InputDecoration(
              labelText: 'Last Name',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Last name is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _companyNameController,
            decoration: const InputDecoration(
              labelText: 'Company Name',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Company name is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _businessNameController,
            decoration: const InputDecoration(
              labelText: 'Business Name',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Business name is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _phoneNumberController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Phone number is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          // Address Title
          Text(
            'Business Address',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),

          // Address Form (reused from carrier)
          AddressForm(
            streetController: _streetController,
            cityController: _cityController,
            stateController: _stateController,
            countryController: _countryController,
            postalCodeController: _postalCodeController,
          ),
          const SizedBox(height: 32),

          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: widget.isLoading ? null : _submit,
              child: widget.isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(),
                    )
                  : Text(widget.submitLabel),
            ),
          ),
        ],
      ),
    );
  }
}
