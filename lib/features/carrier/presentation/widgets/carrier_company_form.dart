// lib/features/carrier/presentation/widgets/carrier_company_form.dart

import 'package:flutter/material.dart';

import 'address_form.dart';

class CarrierCompanyForm
    extends StatefulWidget {

  final void Function({
    required String companyName,
    required String companyEmail,
    required String phoneNumber,
    required String street,
    required String city,
    required String state,
    required String country,
    required String postalCode,
  }) onSubmit;

  final bool isLoading;
  final String? submitLabel;
  final dynamic initialCompany;

  const CarrierCompanyForm({
    super.key,
    required this.onSubmit,
    this.isLoading = false,
    this.submitLabel,
    this.initialCompany,
  });

  @override
  State<CarrierCompanyForm> createState() =>
      _CarrierCompanyFormState();
}

class _CarrierCompanyFormState
    extends State<CarrierCompanyForm> {

  final _formKey =
      GlobalKey<FormState>();

  /// COMPANY

  final _companyNameController =
      TextEditingController();

  final _companyEmailController =
      TextEditingController();

  final _phoneNumberController =
      TextEditingController();

  /// ADDRESS

  final _streetController =
      TextEditingController();

  final _cityController =
      TextEditingController();

  final _stateController =
      TextEditingController();

  final _countryController =
      TextEditingController();

  final _postalCodeController =
      TextEditingController();

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

  void _submit() {

    if (!_formKey.currentState!.validate()) {
      return;
    }

    widget.onSubmit(

      companyName:
          _companyNameController.text.trim(),

      companyEmail:
          _companyEmailController.text.trim(),

      phoneNumber:
          _phoneNumberController.text.trim(),

      street:
          _streetController.text.trim(),

      city:
          _cityController.text.trim(),

      state:
          _stateController.text.trim(),

      country:
          _countryController.text.trim(),

      postalCode:
          _postalCodeController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Form(

      key: _formKey,

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          /// COMPANY NAME

          TextFormField(
            controller:
                _companyNameController,

            decoration:
                const InputDecoration(
              labelText: 'Company Name',
              border: OutlineInputBorder(),
            ),

            validator: (value) {
              if (value == null ||
                  value.trim().isEmpty) {
                return 'Company name is required';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          /// COMPANY EMAIL

          TextFormField(
            controller:
                _companyEmailController,

            keyboardType:
                TextInputType.emailAddress,

            decoration:
                const InputDecoration(
              labelText: 'Company Email',
              border: OutlineInputBorder(),
            ),

            validator: (value) {

              if (value == null ||
                  value.trim().isEmpty) {
                return 'Email is required';
              }

              final emailRegex = RegExp(
                r'^[^@]+@[^@]+\.[^@]+',
              );

              if (!emailRegex.hasMatch(value)) {
                return 'Invalid email';
              }

              return null;
            },
          ),

          const SizedBox(height: 16),

          /// PHONE NUMBER

          TextFormField(
            controller:
                _phoneNumberController,

            keyboardType:
                TextInputType.phone,

            decoration:
                const InputDecoration(
              labelText: 'Phone Number',
              border: OutlineInputBorder(),
            ),

            validator: (value) {
              if (value == null ||
                  value.trim().isEmpty) {
                return 'Phone number is required';
              }
              return null;
            },
          ),

          const SizedBox(height: 24),

          /// ADDRESS TITLE

          Text(
            'Company Address',

            style:
                Theme.of(context)
                    .textTheme
                    .titleMedium,
          ),

          const SizedBox(height: 16),

          /// ADDRESS FORM

          AddressForm(
            streetController:
                _streetController,

            cityController:
                _cityController,

            stateController:
                _stateController,

            countryController:
                _countryController,

            postalCodeController:
                _postalCodeController,
          ),

          const SizedBox(height: 32),

          /// SUBMIT BUTTON

          SizedBox(
            width: double.infinity,
            height: 52,

            child: ElevatedButton(
              onPressed:
                  widget.isLoading
                      ? null
                      : _submit,

              child:
                  widget.isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child:
                              CircularProgressIndicator(),
                        )
                          : Text(
                              widget.submitLabel ?? 'Save Carrier Company',
                            ),
            ),
          ),
        ],
      ),
    );
  }

      @override
      void initState() {
        super.initState();

        final c = widget.initialCompany;
        if (c != null) {
          _companyNameController.text = c.companyName ?? '';
          _companyEmailController.text = c.companyEmail ?? '';
          if (c.address != null) {
            _phoneNumberController.text = c.address.phoneNumber ?? '';
            _streetController.text = c.address.street ?? '';
            _cityController.text = c.address.city ?? '';
            _stateController.text = c.address.state ?? '';
            _countryController.text = c.address.country ?? '';
            _postalCodeController.text = c.address.zip ?? '';
          }
        }
      }
}