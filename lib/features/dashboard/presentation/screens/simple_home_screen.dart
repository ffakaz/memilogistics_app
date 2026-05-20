// lib/features/dashboard/presentation/screens/simple_home_screen.dart
//
// Simple home screen for testing the core setup

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:memilogistics_app/core/network/api_client.dart';
import 'package:memilogistics_app/core/router/app_router.dart';
import 'package:memilogistics_app/core/secure_storage/secure_storage_service.dart';
import 'package:memilogistics_app/core/utils/constants/route_constants.dart';

class SimpleHomeScreen extends StatefulWidget {
  const SimpleHomeScreen({super.key});

  @override
  State<SimpleHomeScreen> createState() => _SimpleHomeScreenState();
}

class _SimpleHomeScreenState extends State<SimpleHomeScreen> {
  List<Map<String, dynamic>> _loads = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final apiClient = context.read<ApiClient>();
      final response = await apiClient.get<Map<String, dynamic>>('/loads');

      if (response.isSuccess && response.data != null) {
        final data = response.data!;
        setState(() {
          _loads = List<Map<String, dynamic>>.from(data['data'] ?? []);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        _showError(response.message ?? 'Failed to load data');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('An error occurred: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _handleLogout() async {
    try {
      final storageService = context.read<SecureStorageService>();
      await storageService.clearAuthData();
      
      if (mounted) {
        context.read<AppRouter>().replace(RouteConstants.login);
      }
    } catch (e) {
      _showError('Logout failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            onPressed: _handleLogout,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: _loads.isEmpty
                  ? const Center(
                      child: Text('No loads available'),
                    )
                  : ListView.builder(
                      itemCount: _loads.length,
                      itemBuilder: (context, index) {
                        final load = _loads[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ListTile(
                            title: Text(
                              '${load['origin']} → ${load['destination']}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Weight: ${load['weight']}'),
                                Text('Price: ${load['price']}'),
                                Text('Status: ${load['status']}'),
                              ],
                            ),
                            trailing: Chip(
                              label: Text(load['status']),
                              backgroundColor: _getStatusColor(load['status']),
                            ),
                            onTap: () {
                              // Navigate to load details (when implemented)
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Load ${load['id']} details'),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to post load screen (when implemented)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Post load screen not implemented yet'),
            ),
          );
        },
        tooltip: 'Post Load',
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping),
            label: 'Load Board',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box),
            label: 'Post Load',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          // Handle navigation (when implemented)
          final screens = ['Dashboard', 'Load Board', 'Post Load', 'Profile'];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${screens[index]} screen not implemented yet'),
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange.shade100;
      case 'assigned':
        return Colors.blue.shade100;
      case 'in_transit':
        return Colors.green.shade100;
      case 'delivered':
        return Colors.grey.shade100;
      default:
        return Colors.grey.shade100;
    }
  }
}