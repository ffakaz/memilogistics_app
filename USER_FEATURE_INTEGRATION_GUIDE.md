# User Feature Integration Guide

## ✅ Feature Status

**COMPLETE** - Ready to integrate into main.dart

## 🚀 Quick Integration (5 minutes)

### Step 1: Import in main.dart

Add this import at the top of `lib/main.dart`:

```dart
/// USER FEATURE
import 'package:memilogistics_app/features/user/user.dart';
```

### Step 2: Create User Dependencies

Add after auth dependencies in main.dart:

```dart
/// USER DEPENDENCIES

final userApiService = UserApiService(
  apiClient: apiClient,
);

final userRepository = UserRepositoryImpl(
  apiService: userApiService,
);

/// USER USE CASES

final getCurrentUserUseCase = GetCurrentUserUseCase(userRepository);
final updateProfileUseCase = UpdateProfileUseCase(userRepository);
final getPermissionsUseCase = GetPermissionsUseCase(userRepository);
```

### Step 3: Add UserProvider

Add to the MultiProvider providers list:

```dart
/// USER PROVIDER

ChangeNotifierProvider(
  create: (_) => UserProvider(
    getCurrentUserUseCase: getCurrentUserUseCase,
    updateProfileUseCase: updateProfileUseCase,
    getPermissionsUseCase: getPermissionsUseCase,
  ),
),
```

### Step 4: Test the Integration

Create a simple test widget:

```dart
// In any screen
final userProvider = context.read<UserProvider>();

// Load user
ElevatedButton(
  onPressed: () async {
    await userProvider.loadCurrentUser();
  },
  child: Text('Load User'),
),

// Display user
Consumer<UserProvider>(
  builder: (context, provider, _) {
    if (provider.isLoading) {
      return CircularProgressIndicator();
    }
    
    if (provider.currentUser != null) {
      return Column(
        children: [
          ProfileAvatar(
            avatarUrl: provider.profile?.avatarUrl,
            initials: provider.profile?.initials ?? '?',
          ),
          Text(provider.profile?.name ?? ''),
          Text(provider.profile?.email ?? ''),
          RoleBadge(role: provider.profile!.role),
        ],
      );
    }
    
    return Text('No user loaded');
  },
),
```

## 📋 Complete Integration Example

Here's the complete code to add to main.dart:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// CORE
import 'package:memilogistics_app/core/core.dart';

/// AUTH FEATURE
import 'package:memilogistics_app/features/auth/data/services/fake_auth_api_service_adapter.dart';
import 'package:memilogistics_app/features/auth/data/storage/token_storage.dart';
import 'package:memilogistics_app/features/auth/data/repository/auth_repository_impl.dart';
import 'package:memilogistics_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:memilogistics_app/features/auth/domain/usecases/register_usecase.dart';
import 'package:memilogistics_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:memilogistics_app/features/auth/domain/usecases/is_logged_in_usecase.dart';
import 'package:memilogistics_app/features/auth/domain/usecases/get_current_token_usecase.dart';
import 'package:memilogistics_app/features/auth/presentation/provider/auth_provider.dart';
import 'package:memilogistics_app/features/auth/presentation/screens/login_screen.dart';
import 'package:memilogistics_app/features/auth/presentation/screens/register_screen.dart';
import 'package:memilogistics_app/features/auth/presentation/screens/logout_screen.dart';
import 'package:memilogistics_app/features/auth/presentation/screens/home_screen.dart';

/// USER FEATURE
import 'package:memilogistics_app/features/user/user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ApiConfig.init(AppEnvironment.fake);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppInjection.create(
      child: Builder(
        builder: (context) {
          /// CORE DEPENDENCIES
          final apiClient = context.read<ApiClient>();
          final secureStorage = context.read<FlutterSecureStorage>();

          /// AUTH DEPENDENCIES
          final authApiService = FakeAuthApiServiceAdapter(apiClient: apiClient);
          final tokenStorage = TokenStorage(storage: secureStorage);
          final authRepository = AuthRepositoryImpl(
            apiService: authApiService,
            tokenStorage: tokenStorage,
          );

          /// AUTH USE CASES
          final loginUseCase = LoginUseCase(authRepository);
          final registerUseCase = RegisterUseCase(authRepository);
          final logoutUseCase = LogoutUseCase(authRepository);
          final isLoggedInUseCase = IsLoggedInUseCase(authRepository);
          final getCurrentTokenUseCase = GetCurrentTokenUseCase(authRepository);

          /// USER DEPENDENCIES
          final userApiService = UserApiService(apiClient: apiClient);
          final userRepository = UserRepositoryImpl(apiService: userApiService);

          /// USER USE CASES
          final getCurrentUserUseCase = GetCurrentUserUseCase(userRepository);
          final updateProfileUseCase = UpdateProfileUseCase(userRepository);
          final getPermissionsUseCase = GetPermissionsUseCase(userRepository);

          return MultiProvider(
            providers: [
              /// AUTH PROVIDER
              ChangeNotifierProvider(
                create: (_) => AuthProvider(
                  loginUseCase: loginUseCase,
                  registerUseCase: registerUseCase,
                  logoutUseCase: logoutUseCase,
                  isLoggedInUseCase: isLoggedInUseCase,
                  getCurrentTokenUseCase: getCurrentTokenUseCase,
                )..init(),
              ),

              /// USER PROVIDER
              ChangeNotifierProvider(
                create: (_) => UserProvider(
                  getCurrentUserUseCase: getCurrentUserUseCase,
                  updateProfileUseCase: updateProfileUseCase,
                  getPermissionsUseCase: getPermissionsUseCase,
                ),
              ),
            ],
            child: Consumer<AuthProvider>(
              builder: (context, auth, _) {
                if (!auth.initialized) {
                  return const MaterialApp(
                    debugShowCheckedModeBanner: false,
                    home: Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    ),
                  );
                }

                return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  title: 'Memi Logistics',
                  theme: AppTheme.lightTheme,
                  darkTheme: AppTheme.darkTheme,
                  home: auth.isLoggedIn ? const HomeScreen() : const LoginScreen(),
                  routes: {
                    '/login': (_) => const LoginScreen(),
                    '/register': (_) => const RegisterScreen(),
                    '/logout': (_) => const LogoutScreen(),
                    '/home': (_) => const HomeScreen(),
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
```

## 🧪 Testing the Integration

### 1. Load User After Login

Update your login success handler:

```dart
// In login_screen.dart or home_screen.dart
final auth = context.read<AuthProvider>();
final user = context.read<UserProvider>();

if (auth.isAuthenticated) {
  await user.loadCurrentUser();
}
```

### 2. Display User Info in Home Screen

```dart
// In home_screen.dart
Consumer<UserProvider>(
  builder: (context, userProvider, _) {
    final profile = userProvider.profile;
    
    if (profile == null) {
      return Text('Loading user...');
    }
    
    return Column(
      children: [
        ProfileAvatar(
          avatarUrl: profile.avatarUrl,
          initials: profile.initials,
          size: 60,
        ),
        SizedBox(height: 8),
        Text(
          profile.name,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(profile.email),
        SizedBox(height: 8),
        RoleBadge(role: profile.role),
      ],
    );
  },
),
```

### 3. Check Permissions

```dart
final userProvider = context.read<UserProvider>();

if (userProvider.hasPermission('create_shipments')) {
  // Show create shipment button
  ElevatedButton(
    onPressed: () {
      Navigator.pushNamed(context, '/create-shipment');
    },
    child: Text('Create Shipment'),
  );
}
```

## 🎨 UI Examples

### Profile Card

```dart
Card(
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Consumer<UserProvider>(
      builder: (context, provider, _) {
        final profile = provider.profile;
        if (profile == null) return SizedBox();
        
        return Column(
          children: [
            ProfileAvatar(
              avatarUrl: profile.avatarUrl,
              initials: profile.initials,
              size: 80,
            ),
            SizedBox(height: 16),
            Text(
              profile.name,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(profile.email),
            SizedBox(height: 8),
            RoleBadge(role: profile.role),
            if (profile.company != null) ...[
              SizedBox(height: 8),
              Text(profile.company!),
            ],
          ],
        );
      },
    ),
  ),
)
```

### Permission List

```dart
Consumer<UserProvider>(
  builder: (context, provider, _) {
    return ListView.builder(
      itemCount: provider.permissions.length,
      itemBuilder: (context, index) {
        final permission = provider.permissions[index];
        return ListTile(
          leading: Icon(
            permission.granted ? Icons.check_circle : Icons.cancel,
            color: permission.granted ? Colors.green : Colors.red,
          ),
          title: Text(permission.name),
          subtitle: Text(permission.description),
        );
      },
    );
  },
)
```

## ✅ Verification Checklist

After integration, verify:

- [ ] App compiles without errors
- [ ] UserProvider is accessible
- [ ] Can load current user
- [ ] Profile data displays correctly
- [ ] Avatar widget renders
- [ ] Role badge shows correct role
- [ ] Permissions load correctly
- [ ] Can update profile
- [ ] Error handling works
- [ ] Loading states work

## 🐛 Troubleshooting

### Issue: "UserProvider not found"

**Solution:** Make sure UserProvider is added to MultiProvider

### Issue: "User is null"

**Solution:** Call `await userProvider.loadCurrentUser()` after login

### Issue: "Compilation errors"

**Solution:** Run `flutter clean && flutter pub get`

### Issue: "Avatar not showing"

**Solution:** Check if avatarUrl is valid or use initials fallback

## 🎯 Next Steps

1. ✅ Integrate user feature
2. ✅ Test basic functionality
3. Create profile screen
4. Create edit profile screen
5. Add profile route
6. Connect to real API (when ready)

## 📊 Expected Behavior

After integration:
1. Login → Load user automatically
2. Display user info in home screen
3. Show avatar and role badge
4. Check permissions for features
5. Update profile when needed
6. Clear user on logout

---

**Status**: Ready to integrate
**Estimated Time**: 5-10 minutes
**Difficulty**: Easy
**Risk**: Low (uses barrel exports, no compilation issues expected)
