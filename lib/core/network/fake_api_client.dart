// lib/core/network/fake_api_client.dart
//
// Fake API client implementation for development and testing

import 'dart:math';
import 'package:memilogistics_app/core/core.dart';

class FakeApiClient implements ApiClient {
  final Random _random = Random();
  
  // Store created carrier company (simulating database)
  Map<String, dynamic>? _carrierCompany;
  
  // Simulate network delay
  Future<void> _delay() async {
    await Future.delayed(Duration(milliseconds: 200 + _random.nextInt(800)));
  }

  @override
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    await _delay();
    
    // Simulate different responses based on path
    if (path.contains('/auth/login')) {
      return _handleLogin<T>();
    } else if (path.contains('/auth/refresh')) {
      return _handleRefresh<T>();
    } else if (path.contains('/user/me')) {
      return _handleGetCurrentUser<T>();
    } else if (path.contains('/user/') && path.contains('/permissions')) {
      return _handleGetPermissions<T>();
    } else if (path.contains('/user/')) {
      return _handleGetUserProfile<T>();
    } else if (path.contains('/carrier/company')) {
      return _handleGetCarrierCompany<T>();
    } else if (path.contains('/loads')) {
      return _handleGetLoads<T>();
    } else if (path.contains('/profile')) {
      return _handleGetProfile<T>();
    }
    
    return ApiResponse<T>.error('Endpoint not found', statusCode: 404);
  }

  @override
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    await _delay();
    
    if (path.contains('/auth/login')) {
      return _handleLogin<T>();
    } else if (path.contains('/auth/register')) {
      return _handleRegister<T>();
    } else if (path.contains('/carrier/company')) {
      return _handleCreateCarrierCompany<T>(data);
    } else if (path.contains('/shipments')) {
      return _handleCreateShipment<T>();
    } else if (path.contains('/loads/create')) {
      return _handleCreateLoad<T>();
    }
    
    return ApiResponse<T>.error('Endpoint not found', statusCode: 404);
  }

  @override
  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    await _delay();
    
    if (path.contains('/user/') && path.contains('/avatar')) {
      return _handleUpdateAvatar<T>();
    } else if (path.contains('/user/')) {
      return _handleUpdateProfile<T>(data);
    } else if (path.contains('/carrier/company')) {
      return _handleUpdateCarrierCompany<T>(data);
    } else if (path.contains('/loads/')) {
      return _handleUpdateLoad<T>();
    }
    
    return ApiResponse<T>.error('Endpoint not found', statusCode: 404);
  }

  @override
  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    await _delay();
    
    if (path.contains('/loads/')) {
      return ApiResponse<T>.success(null as T, statusCode: 204);
    }
    
    return ApiResponse<T>.error('Endpoint not found', statusCode: 404);
  }

  // Fake response handlers
  ApiResponse<T> _handleLogin<T>() {
    final response = {
      'access_token': 'fake_access_token_${_random.nextInt(10000)}',
      'refresh_token': 'fake_refresh_token_${_random.nextInt(10000)}',
      'expires_in': 3600,
      'user': {
        'id': 1,
        'email': 'user@example.com',
        'name': 'John Doe',
        'role': 'driver',
      }
    };
    return ApiResponse<T>.success(response as T);
  }

  ApiResponse<T> _handleRegister<T>() {
    final response = {
      'access_token': 'fake_access_token_${_random.nextInt(10000)}',
      'refresh_token': 'fake_refresh_token_${_random.nextInt(10000)}',
      'expires_in': 3600,
      'expiry': DateTime.now().add(const Duration(hours: 1)).toIso8601String(),
      'user': {
        'id': _random.nextInt(1000) + 1,
        'email': 'newuser@example.com',
        'name': 'New User',
        'role': 'driver',
      }
    };
    return ApiResponse<T>.success(response as T);
  }

  ApiResponse<T> _handleRefresh<T>() {
    final response = {
      'access_token': 'new_fake_access_token_${_random.nextInt(10000)}',
      'refresh_token': 'new_fake_refresh_token_${_random.nextInt(10000)}',
      'expires_in': 3600,
    };
    return ApiResponse<T>.success(response as T);
  }

  ApiResponse<T> _handleGetLoads<T>() {
    final loads = List.generate(10, (index) => {
      'id': index + 1,
      'origin': _getFakeLocation(),
      'destination': _getFakeLocation(),
      'weight': '${_random.nextInt(40) + 10}000 lbs',
      'price': '\$${(_random.nextInt(3000) + 500)}',
      'pickup_date': DateTime.now().add(Duration(days: _random.nextInt(7))).toIso8601String(),
      'delivery_date': DateTime.now().add(Duration(days: _random.nextInt(7) + 7)).toIso8601String(),
      'status': ['pending', 'assigned', 'in_transit', 'delivered'][_random.nextInt(4)],
      'shipper': {
        'name': 'Shipper ${index + 1}',
        'company': 'Company ${index + 1}',
        'phone': '+1-555-${_random.nextInt(900) + 100}-${_random.nextInt(9000) + 1000}',
      }
    });

    final response = {
      'data': loads,
      'total': loads.length,
      'page': 1,
      'per_page': 10,
    };
    
    return ApiResponse<T>.success(response as T);
  }

  ApiResponse<T> _handleCreateLoad<T>() {
    final response = {
      'id': _random.nextInt(1000) + 1,
      'message': 'Load created successfully',
      'status': 'pending',
    };
    return ApiResponse<T>.success(response as T);
  }

  ApiResponse<T> _handleCreateShipment<T>() {
    final response = {
      'id': _random.nextInt(1000) + 1,
      'message': 'Shipment created successfully',
      'status': 'pending',
      'tracking_number': 'SHIP${_random.nextInt(100000).toString().padLeft(5, '0')}',
    };
    return ApiResponse<T>.success(response as T);
  }

  ApiResponse<T> _handleUpdateLoad<T>() {
    final response = {
      'message': 'Load updated successfully',
      'status': 'updated',
    };
    return ApiResponse<T>.success(response as T);
  }

  ApiResponse<T> _handleGetProfile<T>() {
    final response = {
      'id': 1,
      'email': 'user@example.com',
      'name': 'John Doe',
      'role': 'driver',
      'phone': '+1-555-123-4567',
      'company': 'ABC Logistics',
      'license_number': 'DL123456789',
      'created_at': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
    };
    return ApiResponse<T>.success(response as T);
  }

  String _getFakeLocation() {
    final cities = [
      'New York, NY',
      'Los Angeles, CA',
      'Chicago, IL',
      'Houston, TX',
      'Phoenix, AZ',
      'Philadelphia, PA',
      'San Antonio, TX',
      'San Diego, CA',
      'Dallas, TX',
      'San Jose, CA',
    ];
    return cities[_random.nextInt(cities.length)];
  }

  // User endpoints
  ApiResponse<T> _handleGetCurrentUser<T>() {
    final response = {
      'profile': {
        'id': '1',
        'email': 'user@example.com',
        'name': 'John Doe',
        'phone': '+1-555-123-4567',
        'company': 'Swift Transport Solutions',
        'address': '456 Logistics Blvd, Chicago, IL 60601',
        'avatar_url': null,
        'role': 'carrier', // Changed to carrier for carrier dashboard
        'status': 'active',
        'created_at': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      'permissions': [
        {
          'id': 'view_shipments',
          'name': 'View Shipments',
          'description': 'Can view all shipments',
          'granted': true,
        },
        {
          'id': 'create_shipments',
          'name': 'Create Shipments',
          'description': 'Can create new shipments',
          'granted': true,
        },
        {
          'id': 'manage_fleet',
          'name': 'Manage Fleet',
          'description': 'Can manage carrier fleet',
          'granted': true,
        },
        {
          'id': 'manage_drivers',
          'name': 'Manage Drivers',
          'description': 'Can manage drivers',
          'granted': true,
        },
      ],
      'access_token': 'fake_access_token_${_random.nextInt(10000)}',
      'last_login': DateTime.now().toIso8601String(),
    };
    return ApiResponse<T>.success(response as T);
  }

  ApiResponse<T> _handleGetUserProfile<T>() {
    final response = {
      'id': '1',
      'email': 'user@example.com',
      'name': 'John Doe',
      'phone': '+1-555-123-4567',
      'company': 'ABC Logistics',
      'address': '123 Main St, New York, NY 10001',
      'avatar_url': null,
      'role': 'driver',
      'status': 'active',
      'created_at': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
    return ApiResponse<T>.success(response as T);
  }

  ApiResponse<T> _handleUpdateProfile<T>(dynamic data) {
    final updates = data as Map<String, dynamic>? ?? {};
    final response = {
      'id': '1',
      'email': 'user@example.com',
      'name': updates['name'] ?? 'John Doe',
      'phone': updates['phone'] ?? '+1-555-123-4567',
      'company': updates['company'] ?? 'ABC Logistics',
      'address': updates['address'] ?? '123 Main St, New York, NY 10001',
      'avatar_url': updates['avatar_url'],
      'role': 'driver',
      'status': 'active',
      'created_at': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
    return ApiResponse<T>.success(response as T);
  }

  ApiResponse<T> _handleGetPermissions<T>() {
    final response = {
      'permissions': [
        {
          'id': 'view_shipments',
          'name': 'View Shipments',
          'description': 'Can view all shipments',
          'granted': true,
        },
        {
          'id': 'create_shipments',
          'name': 'Create Shipments',
          'description': 'Can create new shipments',
          'granted': true,
        },
        {
          'id': 'edit_shipments',
          'name': 'Edit Shipments',
          'description': 'Can edit existing shipments',
          'granted': true,
        },
        {
          'id': 'delete_shipments',
          'name': 'Delete Shipments',
          'description': 'Can delete shipments',
          'granted': false,
        },
        {
          'id': 'manage_users',
          'name': 'Manage Users',
          'description': 'Can manage user accounts',
          'granted': false,
        },
      ],
    };
    return ApiResponse<T>.success(response as T);
  }

  ApiResponse<T> _handleUpdateAvatar<T>() {
    final response = {
      'message': 'Avatar updated successfully',
      'avatar_url': 'https://example.com/avatars/user_${_random.nextInt(1000)}.jpg',
    };
    return ApiResponse<T>.success(response as T);
  }

  // Carrier Company endpoints
  ApiResponse<T> _handleGetCarrierCompany<T>() {
    // Return 404 if no company has been created yet
    if (_carrierCompany == null) {
      return ApiResponse<T>.error(
        'Carrier company not found. Please create your company profile.',
        statusCode: 404,
      );
    }
    
    return ApiResponse<T>.success(_carrierCompany as T);
  }

  ApiResponse<T> _handleCreateCarrierCompany<T>(dynamic data) {
    final companyData = data as Map<String, dynamic>? ?? {};
    _carrierCompany = {
      'manager_user_id': companyData['manager_user_id'] ?? '1',
      'company_name': companyData['company_name'] ?? 'New Carrier Company',
      'address': companyData['address'] ?? {
        'street': '123 Business St',
        'city': 'New York',
        'state': 'NY',
        'zip': '10001',
        'country': 'USA',
        'phone_number': '+1-555-000-0000',
      },
      'company_email': companyData['company_email'] ?? 'info@carrier.com',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
    return ApiResponse<T>.success(_carrierCompany as T);
  }

  ApiResponse<T> _handleUpdateCarrierCompany<T>(dynamic data) {
    // Return 404 if no company exists
    if (_carrierCompany == null) {
      return ApiResponse<T>.error(
        'Carrier company not found. Please create your company profile first.',
        statusCode: 404,
      );
    }
    
    final updates = data as Map<String, dynamic>? ?? {};
    _carrierCompany = {
      'manager_user_id': updates['manager_user_id'] ?? _carrierCompany!['manager_user_id'],
      'company_name': updates['company_name'] ?? _carrierCompany!['company_name'],
      'address': updates['address'] ?? _carrierCompany!['address'],
      'company_email': updates['company_email'] ?? _carrierCompany!['company_email'],
      'created_at': _carrierCompany!['created_at'],
      'updated_at': DateTime.now().toIso8601String(),
    };
    return ApiResponse<T>.success(_carrierCompany as T);
  }
}
