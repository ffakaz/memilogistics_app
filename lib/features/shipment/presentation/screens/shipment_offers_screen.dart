// lib/features/shipment/presentation/screens/shipment_offers_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:memilogistics_app/features/shipment/presentation/providers/shipment_provider.dart';
import 'package:memilogistics_app/features/shipment_offer/data/models/shipment_offer_model.dart';
import 'package:memilogistics_app/features/shipment/domain/entities/shipment.dart';
import 'package:memilogistics_app/features/shipment/domain/enums/shipment_status.dart';

class ShipmentOffersScreen extends StatefulWidget {
  final int shipmentId;
  const ShipmentOffersScreen({super.key, required this.shipmentId});

  @override
  State<ShipmentOffersScreen> createState() => _ShipmentOffersScreenState();
}

class _ShipmentOffersScreenState extends State<ShipmentOffersScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  Shipment? _shipment;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final provider = context.read<ShipmentProvider>();

    try {
      _shipment = await provider.loadShipmentDetail(widget.shipmentId);
      await provider.fetchShipmentOffers(widget.shipmentId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _acceptOffer(ShipmentOfferModel offer) async {
    final provider = context.read<ShipmentProvider>();
    final carrierId = offer.carrierCompanyId ?? offer.carrierCompany?.id;
    if (carrierId == null || carrierId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'This offer does not include a valid carrier profile id.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final confirmed = await _confirmOfferAction(
      title: 'Accept Offer?',
      message:
          'Assign this shipment to ${_carrierName(offer)} for ETB ${offer.price.toStringAsFixed(2)}?',
      confirmLabel: 'Accept',
    );
    if (!confirmed || !mounted) return;

    try {
      await provider.acceptShipmentOffer(
        shipmentId: widget.shipmentId,
        shipmentOfferId: offer.id,
        carrierId: carrierId,
      );
      if (!mounted) return;
      
      // Refresh shipment state and offers to reflect backend changes
      _shipment = provider.activeShipment ?? provider.getShipmentById(widget.shipmentId);
      
      // Force refresh offers list to show backend state (other offers should be auto-rejected)
      await provider.fetchShipmentOffers(widget.shipmentId);
      
      setState(() {});
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Offer accepted successfully! Shipment assigned to ${_carrierName(offer)}. '
            'All other offers have been automatically rejected.',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to accept offer: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _rejectOffer(ShipmentOfferModel offer) async {
    final provider = context.read<ShipmentProvider>();

    final confirmed = await _confirmOfferAction(
      title: 'Reject Offer?',
      message:
          'Reject the ETB ${offer.price.toStringAsFixed(2)} offer from ${_carrierName(offer)}?',
      confirmLabel: 'Reject',
      destructive: true,
    );
    if (!confirmed || !mounted) return;

    try {
      print('🔴 [UI] Rejecting offer ${offer.id} for shipment ${widget.shipmentId}');
      
      await provider.cancelShipmentOffer(
        shipmentId: widget.shipmentId,
        shipmentOfferId: offer.id,
      );
      
      if (!mounted) return;
      
      print('✅ [UI] Offer ${offer.id} rejected successfully');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Offer from ${_carrierName(offer)} has been rejected.'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      print('❌ [UI] Failed to reject offer ${offer.id}: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to reject offer: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<bool> _confirmOfferAction({
    required String title,
    required String message,
    required String confirmLabel,
    bool destructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: destructive
                ? ElevatedButton.styleFrom(backgroundColor: Colors.red)
                : null,
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ShipmentProvider>();
    final offers = provider.offersCache[widget.shipmentId] ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text('Review Offers')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.redAccent,
                  ),
                  const SizedBox(height: 12),
                  Text('Error: $_errorMessage'),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _loadData,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () async {
                _shipment = await provider.loadShipmentDetail(
                  widget.shipmentId,
                );
                await provider.fetchShipmentOffers(widget.shipmentId);
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (_shipment != null) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Shipment: ${_shipment!.trackingNumber}'),
                            const SizedBox(height: 8),
                            Text('Status: ${_shipment!.status.displayName}'),
                            const SizedBox(height: 8),
                            Text(
                              '${_shipment!.origin} → ${_shipment!.destination}',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  Text(
                    'Offers (${offers.length})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (offers.isEmpty)
                    Center(
                      child: Column(
                        children: const [
                          Icon(
                            Icons.local_offer_outlined,
                            size: 72,
                            color: Color(0xFF90A4AE), // Blue-gray
                          ),
                          SizedBox(height: 8),
                          Text('No offers yet'),
                        ],
                      ),
                    )
                  else
                    ...offers.map((o) => _buildOfferCard(o, provider)).toList(),
                ],
              ),
            ),
    );
  }

  Widget _buildOfferCard(ShipmentOfferModel offer, ShipmentProvider provider) {
    final isSubmitting = provider.isMutatingOffer(offer.id);
    final shipmentAssigned = (_shipment?.assignedCarrierId != null) ||
      (_shipment?.status == ShipmentStatus.assigned);
    final actionsDisabled = isSubmitting || shipmentAssigned;
    final carrierName = _carrierName(offer);
    
    // CRITICAL: Check if THIS specific carrier was assigned
    final isThisCarrierAssigned = _shipment?.assignedCarrierId != null &&
        _shipment!.assignedCarrierId == (offer.carrierCompanyId ?? offer.carrierCompany?.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isThisCarrierAssigned ? 3 : 1,
      color: isThisCarrierAssigned ? const Color(0xFFE8F5E9) : null, // Light green for winner
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: isThisCarrierAssigned 
                      ? const Color(0xFF27AE60) // Green for assigned carrier
                      : const Color(0xFF2C3E50),
                  child: isThisCarrierAssigned
                      ? const Icon(Icons.check, color: Colors.white, size: 20)
                      : Text(
                          carrierName.isEmpty
                              ? 'C'
                              : carrierName.substring(0, 1).toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              carrierName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isThisCarrierAssigned 
                                    ? FontWeight.w800 
                                    : FontWeight.bold,
                              ),
                            ),
                          ),
                          if (isThisCarrierAssigned)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF27AE60),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'ASSIGNED',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(offer.carrierCompany?.companyEmail ?? ''),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'ETB ${offer.price.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isThisCarrierAssigned 
                    ? const Color(0xFF27AE60) 
                    : const Color(0xFF27AE60).withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Submitted: ${_formatDateTime(offer.createdAt)}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            if (shipmentAssigned)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isThisCarrierAssigned 
                      ? const Color(0xFF27AE60).withValues(alpha: 0.1)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isThisCarrierAssigned 
                        ? const Color(0xFF27AE60)
                        : Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isThisCarrierAssigned 
                          ? Icons.check_circle 
                          : Icons.info_outline,
                      color: isThisCarrierAssigned 
                          ? const Color(0xFF27AE60) 
                          : Colors.grey.shade600,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isThisCarrierAssigned
                            ? '✅ This carrier has been assigned to the shipment.'
                            : 'This shipment has been assigned to another carrier.',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isThisCarrierAssigned 
                              ? const Color(0xFF27AE60) 
                              : Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: actionsDisabled
                          ? null
                          : () => _rejectOffer(offer),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                      icon: isSubmitting
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator.adaptive(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.close, size: 18),
                      label: const Text('Reject'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: actionsDisabled
                          ? null
                          : () => _acceptOffer(offer),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF27AE60),
                      ),
                      icon: isSubmitting
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator.adaptive(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.check, size: 18),
                      label: const Text('Accept'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _carrierName(ShipmentOfferModel offer) {
    final name = offer.carrierCompany?.companyName.trim();
    if (name != null && name.isNotEmpty) return name;

    final carrierId = offer.carrierCompanyId ?? offer.carrierCompany?.id;
    return carrierId == null ? 'Carrier' : 'Carrier $carrierId';
  }
}
