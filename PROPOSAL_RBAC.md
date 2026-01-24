# Role-Based Access Control (RBAC) Architecture Proposal

## 1. Executive Summary

This proposal outlines a scalable, clean architecture for managing User, Merchant, and Admin roles.
Unlike the traditional method of checking `if (user.role == 'merchant')` scattered throughout the UI, we propose a **Permission-Based Architecture**.

**Core Concept:**
- **Roles** (User, Merchant, Admin) are assigned to users.
- **Permissions** (e.g., `manageStock`, `viewHome`) are assigned to Roles.
- **UI & Logic** check for **Permissions**, never Roles.

This allows "Merchant" to inherit "User" capabilities simply by assigning the User permission set to the Merchant role in one central place.

## 2. Architecture Overview

### A. The Permission Model (`rbac_constants.dart`)
We define a granular list of capabilities as an Enum.
```dart
enum AppPermission {
  viewHome,
  accessMerchantDashboard,
  manageStock,
  // ...
}
```

### B. The Role Manager (`role_manager.dart`)
This is the "Brain". It maps Roles to Sets of Permissions. This is where the **Inheritance Rule** "Merchant extends User" is codified.
```dart
if (role == UserType.merchant) {
  permissions.addAll(userPermissions); // Inheritance
  permissions.addAll(merchantPermissions);
}
```

### C. The Permission Provider (`permission_provider.dart`)
A state management class (supports Riverpod/Provider/Bloc) that holds the current list of `activePermissions`. It updates automatically when the User logs in or changes.

### D. UI Access Control (`access_control_widget.dart`)
A declarative widget for hiding/showing UI elements.
```dart
AccessControl(
  permission: AppPermission.manageStock,
  child: EditStockButton(),
)
```

## 3. Implementation Steps

### Step 1: Add the Security Module
We have created the `lib/core/security` directory containing all necessary classes.

### Step 2: Register the Provider
Modify your `lib/app.dart` to include the `PermissionProvider`. It needs access to `AuthProvider`.

```dart
// lib/app.dart

MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthProvider()),
    // ... other providers
    
    // ADD THIS:
    ChangeNotifierProxyProvider<AuthProvider, PermissionProvider>(
      create: (context) => PermissionProvider(Provider.of<AuthProvider>(context, listen: false)),
      update: (context, auth, prev) => prev!..update(auth),
    ),
  ],
  // ...
)
```

### Step 3: Update Route Guards
Replace your current `RouteGuards` logic with Permission checks.

**Before (Hard to scale):**
```dart
if (user.type == UserType.merchant) { ... }
```

**After (Scalable):**
```dart
// In generateRoute:
case AppRoutes.merchantDashboard:
  return MaterialPageRoute(
    builder: (_) => PermissionGuard.check(
      context: context,
      permission: AppPermission.accessMerchantDashboard,
      child: MerchantDashboardScreen(),
    ),
  );
```

## 4. Why this is better?

| Feature | Old Approach (Role Checks) | New Approach (Permission Checks) |
| :--- | :--- | :--- |
| **Inheritance** | Hard (`if user == user || user == merchant`) | Automatic (Merchant has `viewHome` permission) |
| **Refactoring** | Nightmare (Find/Replace all "merchant" strings) | Easy (Change mapping in `RoleManager`) |
| **New Roles** | Break everything (What if 'SuperMerchant' appears?) | Seamless (Just map permissions to new role) |
| **Backend Sync** | Difficult | Ready (Just merge backend permission list) |

## 5. Directory Structure
```
lib/core/security/
├── rbac_constants.dart        # Enum definitions
├── role_manager.dart          # Logic & Inheritance rules
├── permission_provider.dart   # State Management integration
├── access_control_widget.dart # Helper for UI
└── permission_guard.dart      # Helper for Navigation
```
