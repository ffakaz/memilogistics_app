import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/enums/safety_option.dart';
import '../../domain/enums/shipment_type.dart';
import '../../domain/enums/weight_unit.dart';

import '../providers/shipment_provider.dart';
import 'package:memilogistics_app/features/shipper/presentation/providers/shipper_company_provider.dart';

class CreateShipmentScreen extends StatefulWidget {
  const CreateShipmentScreen({super.key});

  @override
  State<CreateShipmentScreen> createState() => _CreateShipmentScreenState();
}

class _CreateShipmentScreenState extends State<CreateShipmentScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _amountController = TextEditingController();

  final TextEditingController _pickupController = TextEditingController();

  final TextEditingController _destinationController = TextEditingController();

  DateTime? _pickupDate;

  ShipmentType _shipmentType = ShipmentType.dryGoods;

  WeightUnit _weightUnit = WeightUnit.kg;

  SafetyOption _safetyOption = SafetyOption.normal;

  @override
  void dispose() {
    _amountController.dispose();
    _pickupController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _selectPickupDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      setState(() {
        _pickupDate = selectedDate;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_pickupDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pickup date is required')));
      return;
    }

    final provider = context.read<ShipmentProvider>();
    final shipperProvider = context.read<ShipperCompanyProvider>();

    final shipperCompany = shipperProvider.state.company;
    if (shipperCompany == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complete your shipper profile first.')),
      );
      return;
    }

    try {
      await provider.createShipment(
        shipperName: shipperCompany.companyName,
        shipmentType: _shipmentType,
        amount: double.parse(_amountController.text.trim()),
        unit: _weightUnit,
        pickup: _pickupController.text.trim(),
        destination: _destinationController.text.trim(),
        pickupDate: _pickupDate!,
        safetyOption: _safetyOption,
        // Status will be set to 'pending' by backend automatically
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Shipment created successfully')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create shipment: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ShipmentProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Create Shipment')),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Form(
          key: _formKey,

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Consumer<ShipperCompanyProvider>(
                builder: (context, shipperProvider, _) {
                  final company = shipperProvider.state.company;
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.business_outlined),
                      title: Text(company?.companyName ?? 'Verified shipper'),
                      subtitle: Text(
                        company?.businessName ?? 'Backend profile verified',
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              /// SHIPMENT TYPE
              DropdownButtonFormField<ShipmentType>(
                initialValue: _shipmentType,

                decoration: const InputDecoration(
                  labelText: 'Shipment Type',
                  border: OutlineInputBorder(),
                ),

                items: ShipmentType.values
                    .map(
                      (type) =>
                          DropdownMenuItem(value: type, child: Text(type.name)),
                    )
                    .toList(),

                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _shipmentType = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 16),

              /// AMOUNT + UNIT
              Row(
                children: [
                  Expanded(
                    flex: 2,

                    child: TextFormField(
                      controller: _amountController,

                      keyboardType: TextInputType.number,

                      decoration: const InputDecoration(
                        labelText: 'Amount',
                        border: OutlineInputBorder(),
                      ),

                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Amount is required';
                        }

                        final parsed = double.tryParse(value);

                        if (parsed == null || parsed <= 0) {
                          return 'Invalid amount';
                        }

                        return null;
                      },
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: DropdownButtonFormField<WeightUnit>(
                      initialValue: _weightUnit,

                      decoration: const InputDecoration(
                        labelText: 'Unit',
                        border: OutlineInputBorder(),
                      ),

                      items: WeightUnit.values
                          .map(
                            (unit) => DropdownMenuItem(
                              value: unit,
                              child: Text(unit.name),
                            ),
                          )
                          .toList(),

                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _weightUnit = value;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              /// PICKUP
              TextFormField(
                controller: _pickupController,

                decoration: const InputDecoration(
                  labelText: 'Pickup Point',
                  border: OutlineInputBorder(),
                ),

                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Pickup address is required';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              /// DESTINATION
              TextFormField(
                controller: _destinationController,

                decoration: const InputDecoration(
                  labelText: 'Destination',
                  border: OutlineInputBorder(),
                ),

                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Destination is required';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              /// PICKUP DATE
              InkWell(
                onTap: _selectPickupDate,

                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Pickup Date',
                    border: OutlineInputBorder(),
                  ),

                  child: Text(
                    _pickupDate == null
                        ? 'Select date'
                        : _pickupDate!.toLocal().toString().split(' ')[0],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// SAFETY OPTION
              const Text(
                'Safety Option',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              SegmentedButton<SafetyOption>(
                segments: SafetyOption.values
                    .map(
                      (option) => ButtonSegment<SafetyOption>(
                        value: option,
                        label: Text(option.name),
                      ),
                    )
                    .toList(),
                selected: {_safetyOption},
                onSelectionChanged: (selection) {
                  setState(() {
                    _safetyOption = selection.first;
                  });
                },
              ),

              const SizedBox(height: 24),

              /// SUBMIT BUTTON
              SizedBox(
                width: double.infinity,
                height: 50,

                child: ElevatedButton(
                  onPressed: provider.isLoading ? null : _submit,

                  child: provider.isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(),
                        )
                      : const Text('Create Shipment'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
