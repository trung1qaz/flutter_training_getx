// import 'package:hive_flutter/hive_flutter.dart';
// import '../../core/api_client.dart';
// import '../../core/base_response.dart';
// import '../../core/constants.dart';
// import '../../data/user.dart';
//
// class AuthRepository {
//   // Login method with parsing logic
//   static Future<BaseResponse<Map<String, dynamic>>> login({
//     required int taxCode,
//     required String userName,
//     required String password,
//   }) async {
//     try {
//       final response = await ApiClient.post<Map<String, dynamic>>(
//         AppConstants.loginEndpoint,
//             (data) => _parseLoginResponse(data),
//         data: {
//           "tax_code": taxCode,
//           "user_name": userName,
//           "password": password,
//         },
//       );
//
//       return response;
//     } catch (e) {
//       return BaseResponse.error('Login failed: ${e.toString()}');
//     }
//   }
//
//   // Parse login response
//   static Map<String, dynamic> _parseLoginResponse(dynamic data) {
//     if (data is Map<String, dynamic>) {
//       return data;
//     }
//     throw Exception('Invalid login response format');
//   }
//
//   // Save user data to local storage
//   static Future<void> saveUserData({
//     required String token,
//     required User user,
//     required List<User> recentUsers,
//   }) async {
//     try {
//       final box = Hive.box('authBox');
//       await box.put('authToken', token);
//       await box.put('currentUser', {
//         'tax_code': user.taxCtrl,
//         'user_name': user.userCtrl,
//       });
//       await box.put('userList', recentUsers.map((u) => {
//         'tax_code': u.taxCtrl,
//         'user_name': u.userCtrl,
//       }).toList());
//     } catch (e) {
//       throw Exception('Failed to save user data: $e');
//     }
//   }
//
//   // Load user data from local storage
//   static Future<AuthData?> loadUserData() async {
//     try {
//       final box = Hive.box('authBox');
//       final token = box.get('authToken');
//       final currentUserData = box.get('currentUser');
//       final userListData = box.get('userList', defaultValue: []);
//
//       if (token == null) return null;
//
//       User? currentUser;
//       if (currentUserData != null) {
//         currentUser = User(
//           taxCtrl: currentUserData['tax_code'],
//           userCtrl: currentUserData['user_name'],
//         );
//       }
//
//       final recentUsers = (userListData as List)
//           .map((userData) => User(
//         taxCtrl: userData['tax_code'],
//         userCtrl: userData['user_name'],
//       ))
//           .toList();
//
//       return AuthData(
//         token: token,
//         currentUser: currentUser,
//         recentUsers: recentUsers,
//       );
//     } catch (e) {
//       throw Exception('Failed to load user data: $e');
//     }
//   }
//
//   // Clear user data from local storage
//   static Future<void> clearUserData() async {
//     try {
//       final box = Hive.box('authBox');
//       await box.delete('authToken');
//       await box.delete('currentUser');
//     } catch (e) {
//       throw Exception('Failed to clear user data: $e');
//     }
//   }
//
//   // Update recent users list
//   static Future<void> updateRecentUsers(List<User> recentUsers) async {
//     try {
//       final box = Hive.box('authBox');
//       await box.put('userList', recentUsers.map((u) => {
//         'tax_code': u.taxCtrl,
//         'user_name': u.userCtrl,
//       }).toList());
//     } catch (e) {
//       throw Exception('Failed to update recent users: $e');
//     }
//   }
// }
//
// // Data class to hold authentication data
// class AuthData {
//   final String token;
//   final User? currentUser;
//   final List<User> recentUsers;
//
//   AuthData({
//     required this.token,
//     this.currentUser,
//     required this.recentUsers,
//   });
// }
