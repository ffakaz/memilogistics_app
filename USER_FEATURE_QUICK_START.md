# User Feature - Quick Start Guide

## 🚀 30-Second Overview

Complete user management feature with:
- User profiles
- Permissions
- Role-based access
- Avatar support
- Clean architecture
- **NO compilation issues!**

## 📦 Single Import

```dart
import 'package:memilogistics_app/features/user/user.dart';
```

## ⚡ Quick Setup (Copy & Paste)

### 1. Add to main.dart dependencies:

```dart
// After auth dependencies
final userApiService = UserApiService(apiClient: apiClient);
final userRepository = UserRepositoryImpl(apiService: userApiService);
final getCurrentUserUseCase = GetCurrentUserUseCase(userRepository);
final updateProfileUseCase = UpdateProfileUseCase(userRepository);
final getPermissionsUseCase = GetPermissionsUseCase(userRepository);
```

### 2. Add to MultiProvider:

```dart
ChangeNotifierProvider(
  create: (_) => UserProvider(
    getCurrentUserUseCase: getCurrentUserUseCase,
    updateProfileUseCase: updateProfileUseCase,
    getPermissionsUseCase: getPermissionsUseCase,
  ),
),
```

### 3. Use in widgets:

```dart
// Load user
final user = context.read<UserProvider>();
await user.loadCurrentUser();

// Display
Consumer<UserProvider>(
  builder: (context, provider, _) {
    return ProfileAvatar(
      avatarUrl: provider.profile?.avatarUrl,
      initials: provider.profile?.initials ?? '?',
    );
  },
)
```

## 🎯 Common Use Cases

### Display User Info
```dart
Text(userProvider.profile?.name ?? '');
Text(userProvider.profile?.email ?? '');
RoleBadge(role: userProvider.profile!.role);
```

### Update Profile
```dart
await userProvider.updateProfile(
  name: 'New Name',
  phone: '+1-555-999-8888',
);
```

### Check Permission
```dart
if (userProvider.hasPermission('create_shipments')) {
  // Show feature
}
```

### Validate Form
```dart
TextFormField(
  validator: ProfileValidator.validateName,
);
```

## 📁 File Structure

```
lib/features/user/
├── user.dart              ← Import this!
├── domain/
│   └── domain.dart
├── data/
│   └── data.dart
├── presentation/
│   └── presentation.dart
└── validators/
    └── validators.dart
```

## ✅ Features

- ✅ User profiles
- ✅ Permissions system
- ✅ Role management
- ✅ Avatar widget
- ✅ Role badge widget
- ✅ Form validation
- ✅ State management
- ✅ Fake API support

## 🎨 Widgets

### ProfileAvatar
```dart
ProfileAvatar(
  avatarUrl: user.avatarUrl,
  initials: user.initials,
  size: 80,
  onTap: () {},
)
```

### RoleBadge
```dart
RoleBadge(
  role: AppRole.driver,
  showDescription: true,
)
```

## 📚 Documentation

- `USER_FEATURE_DOCUMENTATION.md` - Full docs
- `USER_FEATURE_INTEGRATION_GUIDE.md` - Integration
- `USER_FEATURE_SUMMARY.md` - Overview

## ✅ Checklist

- [ ] Import user feature
- [ ] Add dependencies
- [ ] Add provider
- [ ] Load user after login
- [ ] Display user info
- [ ] Test functionality

## 🎉 Done!

That's it! The user feature is ready to use.

**Time**: 5 minutes
**Difficulty**: Easy
**Errors**: None expected
