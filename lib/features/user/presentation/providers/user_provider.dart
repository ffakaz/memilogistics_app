// lib/features/user/presentation/providers/user_provider.dart

import 'package:flutter/material.dart';
import '../../domain/entities/current_user.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/entities/user_permission.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../domain/usecases/get_permissions_usecase.dart';

class UserProvider extends ChangeNotifier {
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final GetPermissionsUseCase getPermissionsUseCase;

  UserProvider({
    required this.getCurrentUserUseCase,
    required this.updateProfileUseCase,
    required this.getPermissionsUseCase,
  });

  CurrentUser? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  CurrentUser? get currentUser => _currentUser;
  UserProfile? get profile => _currentUser?.profile;
  List<UserPermission> get permissions => _currentUser?.permissions ?? [];
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasUser => _currentUser != null;

  Future<void> loadCurrentUser() async {
    _setLoading(true);
    _clearError();

    try {
      _currentUser = await getCurrentUserUseCase();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load user: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? company,
    String? address,
  }) async {
    if (_currentUser == null) {
      _setError('No user loaded');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (phone != null) updates['phone'] = phone;
      if (company != null) updates['company'] = company;
      if (address != null) updates['address'] = address;

      final updatedProfile = await updateProfileUseCase(
        userId: _currentUser!.profile.id,
        updates: updates,
      );

      _currentUser = _currentUser!.copyWith(profile: updatedProfile);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update profile: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadPermissions() async {
    if (_currentUser == null) return;

    try {
      final permissions = await getPermissionsUseCase(_currentUser!.profile.id);
      _currentUser = _currentUser!.copyWith(permissions: permissions);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load permissions: $e');
    }
  }

  bool hasPermission(String permissionId) {
    return _currentUser?.hasPermission(permissionId) ?? false;
  }

  void clearUser() {
    _currentUser = null;
    _clearError();
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }
}
