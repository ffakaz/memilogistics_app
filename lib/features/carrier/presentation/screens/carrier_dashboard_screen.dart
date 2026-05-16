import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../user/presentation/providers/user_provider.dart';
import '../../../user/presentation/widgets/profile_avatar.dart';
import '../../../user/presentation/widgets/role_badge.dart';
import '../../../auth/presentation/provider/auth_provider.dart';
import '../providers/carrier_company_provider.dart';
import '../pages/create_carrier_company_page.dart';
import '../pages/edit_carrier_company_page.dart';
import '../pages/carrier_company_page.dart';
import 'load_board_screen.dart';
import '../../../bid/presentation/screens/my_bids_screen.dart';
import '../../../shipment/presentation/screens/my_shipments_screen.dart';
import '../../../../core/utils/constants/route_constants.dart';

class CarrierDashboardScreen extends StatefulWidget {
  const CarrierDashboardScreen({super.key});

  @override
  State<CarrierDashboardScreen> createState() => _CarrierDashboardScreenState();
}

class _CarrierDashboardScreenState extends State<CarrierDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Load user and carrier company data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = context.read<UserProvider>();
      final carrierProvider = context.read<CarrierCompanyProvider>();
      
      // Load user data if not already loaded
      if (userProvider.currentUser == null) {
        userProvider.loadCurrentUser();
      }
      
      // Load carrier company data
      carrierProvider.getCarrierCompany();
    });
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final carrierProvider = context.watch<CarrierCompanyProvider>();
    final user = userProvider.currentUser;

    // Show loading state while data is being fetched
    if (userProvider.isLoading || (user == null && !userProvider.hasUser)) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Show error state if user failed to load
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Carrier Dashboard')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                userProvider.errorMessage ?? 'Failed to load user data',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => userProvider.loadCurrentUser(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Carrier Dashboard'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Navigate to notifications
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications coming soon')),
              );
            },
            tooltip: 'Notifications',
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // TODO: Navigate to settings
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings coming soon')),
              );
            },
            tooltip: 'Settings',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            tooltip: 'More options',
            onSelected: (value) {
              if (value == 'logout') {
                _showLogoutDialog(context);
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20),
                    SizedBox(width: 12),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section with User Profile
                  _buildHeaderSection(user, carrierProvider),

                  const SizedBox(height: 16),

                  // Statistics Cards
                  _buildStatisticsSection(),

                  const SizedBox(height: 24),

                  // Fleet Overview
                  _buildFleetOverview(),

                  const SizedBox(height: 24),

                  // Active Loads
                  _buildActiveLoads(),

                  const SizedBox(height: 24),

                  // Recent Activity
                  _buildRecentActivity(),

                  const SizedBox(height: 24),

                  // Quick Actions
                  _buildQuickActions(context),

                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildHeaderSection(dynamic user, CarrierCompanyProvider carrierProvider) {
    final company = carrierProvider.state.company;
    final isLoadingCompany = carrierProvider.state.isLoading;
    final hasCompanyError = carrierProvider.state.error != null;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[700]!, Colors.blue[500]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Company Name Section - Most Prominent
          if (company != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.business,
                      color: Colors.blue[700],
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          company.companyName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'CARRIER COMPANY',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditCarrierCompanyPage(company: company),
                        ),
                      ).then((_) {
                        carrierProvider.getCarrierCompany();
                      });
                    },
                    tooltip: 'Edit Company',
                  ),
                ],
              ),
            ),
          ],
          
          // User Profile and Company Details
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Profile
                Row(
                  children: [
                    ProfileAvatar(
                      initials: _getInitials(user.profile.name),
                      avatarUrl: user.profile.avatarUrl,
                      size: 48,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.profile.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          RoleBadge(role: user.profile.role),
                        ],
                      ),
                    ),
                  ],
                ),
                
                // Company Loading State
                if (isLoadingCompany) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 16),
                        Text(
                          'Loading company information...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ]
                // Company Error or Not Set Up
                else if (hasCompanyError || company == null) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.orange.shade200,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.warning_amber,
                                color: Colors.orange[700],
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Company Profile Not Set Up',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    hasCompanyError 
                                      ? (carrierProvider.state.error ?? 'Please complete your company profile')
                                      : 'Create your company profile to access Load Board and submit bids',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const CreateCarrierCompanyPage(),
                                ),
                              ).then((_) {
                                carrierProvider.getCarrierCompany();
                              });
                            },
                            icon: const Icon(Icons.add_business, size: 22),
                            label: const Text(
                              'Create Company Profile',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.blue[700],
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ]
                // Company Details
                else ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        // Email
                        _buildInfoRow(
                          Icons.email_outlined,
                          'Email',
                          company.companyEmail,
                        ),
                        const SizedBox(height: 12),
                        Divider(
                          color: Colors.white.withValues(alpha: 0.2),
                          height: 1,
                        ),
                        const SizedBox(height: 12),
                        // Location
                        _buildInfoRow(
                          Icons.location_on_outlined,
                          'Location',
                          '${company.address.city}, ${company.address.state}',
                        ),
                        const SizedBox(height: 12),
                        Divider(
                          color: Colors.white.withValues(alpha: 0.2),
                          height: 1,
                        ),
                        const SizedBox(height: 12),
                        // Phone
                        _buildInfoRow(
                          Icons.phone_outlined,
                          'Phone',
                          company.address.phoneNumber,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CarrierCompanyPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.info_outline, size: 18),
                      label: const Text(
                        'View Full Company Details',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.5),
                          width: 1.5,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Overview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Active Loads',
                  '24',
                  Icons.local_shipping,
                  Colors.blue,
                  '+3 today',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Available Trucks',
                  '18',
                  Icons.airport_shuttle,
                  Colors.green,
                  '75% capacity',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Drivers',
                  '32',
                  Icons.person,
                  Colors.orange,
                  '28 active',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Revenue',
                  '\$45.2K',
                  Icons.attach_money,
                  Colors.purple,
                  'This month',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFleetOverview() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Fleet Status',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Navigate to fleet management
                },
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildFleetItem('Dry Van', 12, 8, Colors.blue),
                const Divider(height: 24),
                _buildFleetItem('Refrigerated', 8, 6, Colors.cyan),
                const Divider(height: 24),
                _buildFleetItem('Flatbed', 6, 4, Colors.orange),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFleetItem(String type, int total, int available, Color color) {
    final percentage = (available / total * 100).toInt();

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.local_shipping, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                type,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: available / total,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$percentage%',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              'of $total',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActiveLoads() {
    final loads = [
      {
        'id': 'LD-2024-001',
        'origin': 'Chicago, IL',
        'destination': 'Dallas, TX',
        'status': 'In Transit',
        'driver': 'John Smith',
        'progress': 0.65,
        'eta': '4 hours',
      },
      {
        'id': 'LD-2024-002',
        'origin': 'Los Angeles, CA',
        'destination': 'Phoenix, AZ',
        'status': 'Loading',
        'driver': 'Mike Johnson',
        'progress': 0.15,
        'eta': '12 hours',
      },
      {
        'id': 'LD-2024-003',
        'origin': 'New York, NY',
        'destination': 'Boston, MA',
        'status': 'In Transit',
        'driver': 'Sarah Williams',
        'progress': 0.85,
        'eta': '1 hour',
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Active Loads',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Navigate to all loads
                },
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...loads.map((load) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildLoadCard(load),
              )),
        ],
      ),
    );
  }

  Widget _buildLoadCard(Map<String, dynamic> load) {
    Color statusColor;
    switch (load['status']) {
      case 'In Transit':
        statusColor = Colors.blue;
        break;
      case 'Loading':
        statusColor = Colors.orange;
        break;
      case 'Delivered':
        statusColor = Colors.green;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                load['id'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  load['status'],
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  load['origin'],
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.flag, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  load['destination'],
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: load['progress'],
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.person, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    load['driver'],
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'ETA: ${load['eta']}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    final activities = [
      {
        'icon': Icons.check_circle,
        'color': Colors.green,
        'title': 'Load LD-2024-045 delivered',
        'time': '15 minutes ago',
      },
      {
        'icon': Icons.local_shipping,
        'color': Colors.blue,
        'title': 'Driver assigned to LD-2024-046',
        'time': '1 hour ago',
      },
      {
        'icon': Icons.warning,
        'color': Colors.orange,
        'title': 'Maintenance due for Truck #TRK-012',
        'time': '2 hours ago',
      },
      {
        'icon': Icons.person_add,
        'color': Colors.purple,
        'title': 'New driver onboarded: Alex Brown',
        'time': '3 hours ago',
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: activities
                  .asMap()
                  .entries
                  .map((entry) => Column(
                        children: [
                          if (entry.key > 0) const Divider(height: 24),
                          _buildActivityItem(
                            entry.value['icon'] as IconData,
                            entry.value['color'] as Color,
                            entry.value['title'] as String,
                            entry.value['time'] as String,
                          ),
                        ],
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
    IconData icon,
    Color color,
    String title,
    String time,
  ) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                time,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final carrierProvider = context.watch<CarrierCompanyProvider>();
    final company = carrierProvider.state.company;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          // Primary Actions - Bidding Workflow
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  'Find Loads',
                  Icons.search,
                  Colors.green,
                  () {
                    if (company == null) {
                      _showCompanyRequiredDialog(context);
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoadBoardScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  'My Bids',
                  Icons.local_offer,
                  Colors.orange,
                  () {
                    if (company == null) {
                      _showCompanyRequiredDialog(context);
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MyBidsScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  'My Shipments',
                  Icons.local_shipping,
                  Colors.blue,
                  () {
                    if (company == null) {
                      _showCompanyRequiredDialog(context);
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MyShipmentsScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  company == null ? 'Setup Company' : 'Company Profile',
                  company == null ? Icons.add_business : Icons.business,
                  Colors.purple,
                  () {
                    if (company == null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateCarrierCompanyPage(),
                        ),
                      ).then((_) {
                        carrierProvider.getCarrierCompany();
                      });
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CarrierCompanyPage(),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Secondary Actions
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  'Manage Fleet',
                  Icons.airport_shuttle,
                  Colors.teal,
                  () {
                    // TODO: Navigate to fleet management
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fleet management coming soon')),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  'Reports',
                  Icons.bar_chart,
                  Colors.indigo,
                  () {
                    // TODO: Navigate to reports
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Reports coming soon')),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCompanyRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.orange),
              SizedBox(width: 12),
              Text('Company Profile Required'),
            ],
          ),
          content: const Text(
            'You need to create your company profile before accessing this feature.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateCarrierCompanyPage(),
                  ),
                ).then((_) {
                  context.read<CarrierCompanyProvider>().getCarrierCompany();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Create Profile'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.logout, color: Colors.red),
              SizedBox(width: 12),
              Text('Logout'),
            ],
          ),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await _performLogout(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performLogout(BuildContext context) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Logging out...'),
                  ],
                ),
              ),
            ),
          );
        },
      );

      // Perform logout
      final authProvider = context.read<AuthProvider>();
      await authProvider.logout();

      // Clear user data
      final userProvider = context.read<UserProvider>();
      userProvider.clearUser();

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Navigate to login screen
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          RouteConstants.login,
          (route) => false,
        );
      }
    } catch (e) {
      // Close loading dialog if still open
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _performLogout(context),
            ),
          ),
        );
      }
    }
  }
}

