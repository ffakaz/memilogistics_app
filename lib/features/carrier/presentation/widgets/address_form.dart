// lib/features/carrier/presentation/widgets/address_form.dart

import 'package:flutter/material.dart';

class AddressForm extends StatelessWidget {
  final TextEditingController streetController;

  final TextEditingController cityController;

  final TextEditingController stateController;

  final TextEditingController countryController;

  final TextEditingController postalCodeController;

  const AddressForm({
    super.key,
    required this.streetController,
    required this.cityController,
    required this.stateController,
    required this.countryController,
    required this.postalCodeController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// STREET
        TextFormField(
          controller: streetController,

          decoration: const InputDecoration(
            labelText: 'Street',
            border: OutlineInputBorder(),
          ),

          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Street is required';
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        /// CITY
        TextFormField(
          controller: cityController,

          decoration: const InputDecoration(
            labelText: 'City',
            border: OutlineInputBorder(),
          ),

          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'City is required';
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        /// STATE
        TextFormField(
          controller: stateController,

          decoration: const InputDecoration(
            labelText: 'State',
            border: OutlineInputBorder(),
          ),

          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'State is required';
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        /// COUNTRY
        TextFormField(
          controller: countryController,

          decoration: const InputDecoration(
            labelText: 'Country',
            border: OutlineInputBorder(),
          ),

          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Country is required';
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        /// POSTAL CODE
        TextFormField(
          controller: postalCodeController,

          decoration: const InputDecoration(
            labelText: 'Postal Code',
            border: OutlineInputBorder(),
          ),

          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Postal code is required';
            }
            return null;
          },
        ),
      ],
    );
  }
}
