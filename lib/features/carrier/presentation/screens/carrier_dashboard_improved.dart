// lib/features/carrier/presentation/screens/carrier_dashboard_improved.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/provider/auth_provider.dart';
import '../../../shipment/presentation/providers/shipment_provider.dart';
import '../../../shipment_offer/presentation/providers/shipment_offer_provider.dart';
import '../../presentation/providers/carrier_company_provider.dart';
import '../pages/carrier_company_page.dart';
import '../pages/edit_carrier_company_page.dart';
import '../widgets/carrier_profile_avatar.dart';
import '../../../../core/utils/constants/route_constants.dart';
import '../../../shipment/domain/entities/shipment.dart';
import '../../domain/entities/carrier_company.dart';

class CarrierDashboardImproved extends StatefulWidget {
  const CarrierDashboardImproved({super.key});

  @override
  State<CarrierDashboardImproved> createState() =>
      _CarrierDashboardImprovedState();
}

class _CarrierDashboardImprovedState extends State<CarrierDashboardImproved> {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _filterStatus;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load available shipments for carriers
      try {
        context.read<ShipmentProvider>().getAvailableShipments();
      } catch (_) {}
      // Load carrier's offers
      try {
        context.read<ShipmentOfferProvider>().loadMyOffers();
      } catch (_) {}
      // Load carrier company details
      try {
        context.read<CarrierCompanyProvider>().ensureProfileLoaded();
      } catch (_) {}
      // Load shipments assigned to this carrier
      try {
        context.read<ShipmentProvider>().getMyShipments();
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CarrierCompanyProvider>(
      builder: (context, carrierProvider, _) {
        final company = carrierProvider.state.company;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Carrier Dashboard'),
            backgroundColor: const Color(0xFF2C3E50),
            actions: [
              _CarrierProfileMenu(company: company),
              const SizedBox(width: 10),
            ],
          ),
          body: IndexedStack(
            index: _selectedIndex,
            children: [
              _buildLoadBoardTab(),
              _buildMyOffersTab(),
              _buildProfileTab(),
            ],
          ),
          // Bottom navigation for switching tabs
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.view_list),
                label: 'Load Board',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.local_offer),
                label: 'My Offers',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadBoardTab() {
    return Consumer<ShipmentProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Error loading shipments',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  provider.errorMessage!,
                  style: TextStyle(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => provider.getAvailableShipments(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
          );
        }

        // Apply search and filter locally for responsiveness
        var shipments = provider.shipments;

        final query = _searchQuery.trim().toLowerCase();
        if (query.isNotEmpty) {
          shipments = shipments.where((s) {
            final tn = (s.trackingNumber ?? '').toLowerCase();
            final pick = s.pickupLocation.address.toLowerCase();
            final dest = s.destinationLocation.address.toLowerCase();
            return tn.contains(query) ||
                pick.contains(query) ||
                dest.contains(query);
          }).toList();
        }

        if (_filterStatus != null && _filterStatus!.isNotEmpty) {
          final fs = _filterStatus!.toLowerCase();
          shipments = shipments
              .where(
                (s) =>
                    s.status.name.toLowerCase().contains(fs) ||
                    _formatStatus(s.status.name).toLowerCase().contains(fs),
              )
              .toList();
        }

        if (shipments.isEmpty) {
          return Column(
            children: [
              // Search and filter header
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          hintText:
                              'Search loads by tracking, origin, destination',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (v) => setState(() => _searchQuery = v),
                      ),
                    ),
                    const SizedBox(width: 8),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.filter_list),
                      onSelected: (v) =>
                          setState(() => _filterStatus = v == 'All' ? null : v),
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'All', child: Text('All')),
                        PopupMenuItem(value: 'Pending', child: Text('Pending')),
                        PopupMenuItem(
                          value: 'Assigned',
                          child: Text('Assigned'),
                        ),
                        PopupMenuItem(
                          value: 'In Transit',
                          child: Text('In Transit'),
                        ),
                        PopupMenuItem(
                          value: 'Delivered',
                          child: Text('Delivered'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 80,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No Available Loads',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Check back later for new shipments',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText:
                            'Search loads by tracking, origin, destination',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (v) => setState(() => _searchQuery = v),
                    ),
                  ),
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.filter_list),
                    onSelected: (v) =>
                        setState(() => _filterStatus = v == 'All' ? null : v),
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'All', child: Text('All')),
                      PopupMenuItem(value: 'Pending', child: Text('Pending')),
                      PopupMenuItem(value: 'Assigned', child: Text('Assigned')),
                      PopupMenuItem(
                        value: 'In Transit',
                        child: Text('In Transit'),
                      ),
                      PopupMenuItem(
                        value: 'Delivered',
                        child: Text('Delivered'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => provider.getAvailableShipments(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: shipments.length,
                  itemBuilder: (context, index) {
                    return _buildShipmentCard(shipments[index]);
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildShipmentCard(Shipment shipment) {
    return GestureDetector(
      onTap: () {
        final shipmentId = shipment.id;
        if (shipmentId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Shipment details are unavailable')),
          );
          return;
        }

        // Navigate to shipment details
        Navigator.pushNamed(
          context,
          RouteConstants.shipmentDetails,
          arguments: shipmentId,
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          shipment.trackingNumber ?? 'N/A',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ID: ${shipment.id}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (shipment.offerCount > 0) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${shipment.offerCount} offer${shipment.offerCount > 1 ? 's' : ''}',
                              style: TextStyle(
                                color: Colors.orange.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Dynamic status badge
                  Builder(
                    builder: (context) {
                      final status = shipment.status.name.toLowerCase();
                      final statusColor = _getStatusColor(status);
                      final statusIcon = _getStatusIcon(status);
                      final label = _formatStatus(status);

                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: statusColor.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(statusIcon, size: 14, color: statusColor),
                            const SizedBox(width: 6),
                            Text(
                              label,
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),

              // Route
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.trip_origin,
                              size: 16,
                              color: Color(0xFF27AE60),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'From: ${_formatLocation(shipment.pickupLocation.address)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 16,
                              color: Color(0xFFE74C3C),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'To: ${_formatLocation(shipment.destinationLocation.address)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Details
              Row(
                children: [
                  Expanded(
                    child: _buildDetailChip(
                      Icons.scale,
                      '${shipment.amount} ${shipment.unit.name}',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildDetailChip(
                      Icons.calendar_today,
                      _formatDate(shipment.pickupDate),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildDetailChip(
                      shipment.safetyOption.name == 'fragile'
                          ? Icons.warning
                          : Icons.check_circle,
                      shipment.safetyOption.name == 'fragile'
                          ? 'Fragile'
                          : 'Standard',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showMakeOfferDialog(shipment),
                  icon: const Icon(Icons.local_offer, size: 20),
                  label: const Text('Make Offer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C3E50),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
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

  Widget _buildDetailChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF2C3E50)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF2C3E50),
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyOffersTab() {
    return Consumer<ShipmentOfferProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                const Text(
                  'Error loading offers',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  provider.errorMessage!,
                  style: TextStyle(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => provider.loadMyOffers(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
          );
        }

        final offers = provider.offers;

        if (offers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.local_offer_outlined,
                  size: 80,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 16),
                Text(
                  'No Offers Yet',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Make offers on available shipments',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => setState(() => _selectedIndex = 0),
                  icon: const Icon(Icons.view_list),
                  label: const Text('View Load Board'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.loadMyOffers(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: offers.length,
            itemBuilder: (context, index) {
              final offer = offers[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Offer #${offer.id}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          Text(
                            '\$${offer.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF27AE60),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Shipment: ${offer.shipmentTrackingNumber}',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Submitted: ${_formatDateTime(offer.createdAt)}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _showCancelOfferDialog(offer.id),
                          icon: const Icon(Icons.cancel, size: 18),
                          label: const Text('Cancel Offer'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildProfileTab() {
    return Consumer<CarrierCompanyProvider>(
      builder: (context, companyProvider, _) {
        final state = companyProvider.state;

        if (state.isLoading && state.company == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.error != null && state.company == null) {
          return _DashboardMessageState(
            icon: Icons.cloud_off,
            title: 'Profile unavailable',
            message: state.error!,
            actionLabel: 'Retry',
            onAction: () =>
                companyProvider.ensureProfileLoaded(forceRefresh: true),
          );
        }

        final company = state.company;

        if (company == null) {
          return _DashboardMessageState(
            icon: Icons.business_outlined,
            title: 'Carrier profile required',
            message:
                'Complete your company profile to access carrier operations.',
            actionLabel: 'Create Profile',
            onAction: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CarrierCompanyPage()),
              );
            },
          );
        }

        return RefreshIndicator(
          onRefresh: () =>
              companyProvider.ensureProfileLoaded(forceRefresh: true),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      CarrierProfileAvatar(profile: company, size: 72),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              company.companyName,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2C3E50),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(company.companyEmail),
                            const SizedBox(height: 6),
                            Text(company.address.phoneNumber),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildProfileItem(
                        Icons.business,
                        'Company',
                        company.companyName,
                      ),
                      const Divider(height: 24),
                      _buildProfileItem(
                        Icons.email,
                        'Company Email',
                        company.companyEmail,
                      ),
                      const Divider(height: 24),
                      _buildProfileItem(
                        Icons.phone,
                        'Phone',
                        company.address.phoneNumber,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildProfileItem(
                        Icons.route,
                        'Street',
                        company.address.street,
                      ),
                      const Divider(height: 24),
                      _buildProfileItem(
                        Icons.location_city,
                        'City / State',
                        '${company.address.city}, ${company.address.state}',
                      ),
                      const Divider(height: 24),
                      _buildProfileItem(
                        Icons.public,
                        'Country',
                        company.address.country,
                      ),
                      const Divider(height: 24),
                      _buildProfileItem(
                        Icons.markunread_mailbox,
                        'ZIP',
                        company.address.zip,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            EditCarrierCompanyPage(company: company),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit Profile'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF2C3E50).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF2C3E50), size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showMakeOfferDialog(Shipment shipment) {
    final priceController = TextEditingController();
    String? priceError;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Make Offer'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Shipment: ${shipment.trackingNumber}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Text(
                'From: ${_formatLocation(shipment.pickupLocation.address)}',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                'To: ${_formatLocation(shipment.destinationLocation.address)}',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                'Weight: ${shipment.amount} ${shipment.unit.name}',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: priceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Your Offer Price',
                  prefixText: '\$ ',
                  border: const OutlineInputBorder(),
                  errorText: priceError,
                ),
                onChanged: (_) => setStateDialog(() => priceError = null),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final text = priceController.text.trim();
                final regex = RegExp(r'^\d+(?:\.\d{1,2})?$');
                if (text.isEmpty || !regex.hasMatch(text)) {
                  setStateDialog(
                    () => priceError = 'Enter a valid price (up to 2 decimals)',
                  );
                  return;
                }

                final price = double.tryParse(text);
                if (price == null || price <= 0) {
                  setStateDialog(
                    () => priceError = 'Price must be greater than 0',
                  );
                  return;
                }

                if (price > 10000000) {
                  setStateDialog(() => priceError = 'Price seems too large');
                  return;
                }

                Navigator.pop(context);

                try {
                  await context.read<ShipmentProvider>().submitShipmentOffer(
                    shipmentId: shipment.id!,
                    price: price,
                  );

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Offer submitted successfully!'),
                      ),
                    );
                    // Refresh offers
                    context.read<ShipmentOfferProvider>().loadMyOffers();
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to submit offer: $e')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2C3E50),
              ),
              child: const Text('Submit Offer'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCancelOfferDialog(int offerId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Offer'),
        content: const Text('Are you sure you want to cancel this offer?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              try {
                await context.read<ShipmentOfferProvider>().cancelOffer(
                  offerId,
                );

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Offer cancelled successfully'),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to cancel offer: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  String _formatDateTime(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatLocation(String address) {
    // Capitalize first letter of each word for better readability
    if (address.isEmpty) return 'Unknown';
    return address
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'assigned':
        return Colors.blue;
      case 'pickedup':
      case 'picked_up':
        return Colors.purple;
      case 'intransit':
      case 'in_transit':
        return Colors.indigo;
      case 'arrivedatdestination':
      case 'arrived_at_destination':
        return Colors.teal;
      case 'delivered':
        return Colors.green;
      case 'completed':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.pending;
      case 'assigned':
        return Icons.assignment_turned_in;
      case 'pickedup':
      case 'picked_up':
        return Icons.inventory;
      case 'intransit':
      case 'in_transit':
        return Icons.local_shipping;
      case 'arrivedatdestination':
      case 'arrived_at_destination':
        return Icons.place;
      case 'delivered':
        return Icons.check_circle;
      case 'completed':
        return Icons.done_all;
      default:
        return Icons.info;
    }
  }

  String _formatStatus(String status) {
    return status
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(0)}')
        .replaceAll('_', ' ')
        .trim()
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? word
              : word[0].toUpperCase() + word.substring(1).toLowerCase(),
        )
        .join(' ');
  }
}

class _CarrierProfileMenu extends StatelessWidget {
  final CarrierCompany? company;

  const _CarrierProfileMenu({required this.company});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_CarrierProfileAction>(
      tooltip: 'Profile menu',
      offset: const Offset(0, 52),
      onSelected: (action) async {
        switch (action) {
          case _CarrierProfileAction.view:
            Navigator.pushNamed(context, RouteConstants.carrierProfile);
            break;
          case _CarrierProfileAction.edit:
            final profile = company;
            if (profile == null) return;
            context.read<CarrierCompanyProvider>().clearError();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EditCarrierCompanyPage(company: profile),
              ),
            );
            break;
          case _CarrierProfileAction.logout:
            await context.read<AuthProvider>().logout();
            if (!context.mounted) return;
            context.read<CarrierCompanyProvider>().clearProfile();
            Navigator.pushNamedAndRemoveUntil(
              context,
              RouteConstants.login,
              (_) => false,
            );
            break;
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: _CarrierProfileAction.view,
          child: ListTile(
            leading: Icon(Icons.business_outlined),
            title: Text('View Profile'),
          ),
        ),
        PopupMenuItem(
          value: _CarrierProfileAction.edit,
          child: ListTile(
            leading: Icon(Icons.edit_outlined),
            title: Text('Edit Profile'),
          ),
        ),
        PopupMenuDivider(),
        PopupMenuItem(
          value: _CarrierProfileAction.logout,
          child: ListTile(leading: Icon(Icons.logout), title: Text('Logout')),
        ),
      ],
      child: CarrierProfileAvatar(profile: company, size: 42),
    );
  }
}

enum _CarrierProfileAction { view, edit, logout }

class _DashboardMessageState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  const _DashboardMessageState({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 60, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}
