import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:restaurant_td/constant/constant.dart';
import 'package:restaurant_td/main.dart';

class SupabaseService {
  // ─── User Management ─────────────────────────────────────────

  /// Get current user
  static User? getCurrentUser() {
    return supabase.auth.currentUser;
  }

  /// Check if user is logged in
  static bool isLoggedIn() {
    return supabase.auth.currentUser != null;
  }

  /// Get user profile by ID
  static Future<Map<String, dynamic>?> getUserProfile(String id) async {
    final response =
        await supabase.from('users').select().eq('id', id).single();
    return response;
  }

  /// Update user profile
  static Future<void> updateUser(Map<String, dynamic> userData) async {
    await supabase.from('users').update(userData).eq('id', userData['id']);
  }

  /// Get user by email
  static Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final response =
        await supabase.from('users').select().eq('email', email).single();
    return response;
  }

  /// Get vendor by ID
  static Future<Map<String, dynamic>?> getVendorById(String vendorId) async {
    final response =
        await supabase.from('vendors').select().eq('id', vendorId).single();
    return response;
  }

  /// Update vendor
  static Future<void> updateVendor(Map<String, dynamic> vendorData) async {
    await supabase
        .from('vendors')
        .update(vendorData)
        .eq('id', vendorData['id']);
  }

  /// Create new vendor
  static Future<Map<String, dynamic>> createVendor(
      Map<String, dynamic> vendorData) async {
    final response =
        await supabase.from('vendors').insert(vendorData).select().single();
    return response;
  }

  // ─── Story Management ────────────────────────────────────────

  /// Get story by vendor ID
  static Future<Map<String, dynamic>?> getStory(String vendorId) async {
    final response = await supabase
        .from('story')
        .select()
        .eq('vendor_id', vendorId)
        .single();
    return response;
  }

  /// Add or update story
  static Future<void> addOrUpdateStory(Map<String, dynamic> storyData) async {
    await supabase
        .from('story')
        .upsert(storyData)
        .eq('vendor_id', storyData['vendor_id']);
  }

  /// Remove story
  static Future<void> removeStory(String vendorId) async {
    await supabase.from('story').delete().eq('vendor_id', vendorId);
  }

  // ─── Product Management ──────────────────────────────────────

  /// Get products by vendor ID
  static Future<List<Map<String, dynamic>>> getProducts(String vendorId) async {
    final response = await supabase
        .from('vendor_products')
        .select()
        .eq('vendor_id', vendorId)
        .order('created_at', ascending: false);
    return response;
  }

  /// Get product by ID
  static Future<Map<String, dynamic>?> getProductById(String productId) async {
    final response = await supabase
        .from('vendor_products')
        .select()
        .eq('id', productId)
        .single();
    return response;
  }

  /// Update product
  static Future<void> updateProduct(Map<String, dynamic> productData) async {
    await supabase
        .from('vendor_products')
        .update(productData)
        .eq('id', productData['id']);
  }

  /// Delete product
  static Future<void> deleteProduct(String productId) async {
    await supabase.from('vendor_products').delete().eq('id', productId);
  }

  /// Create product
  static Future<Map<String, dynamic>> createProduct(
      Map<String, dynamic> productData) async {
    final response = await supabase
        .from('vendor_products')
        .insert(productData)
        .select()
        .single();
    return response;
  }

  // ─── Order Management ────────────────────────────────────────

  /// Get order by ID
  static Future<Map<String, dynamic>?> getOrderById(String orderId) async {
    final response = await supabase
        .from('restaurant_orders')
        .select()
        .eq('id', orderId)
        .single();
    return response;
  }

  /// Update order
  static Future<void> updateOrder(Map<String, dynamic> orderData) async {
    await supabase
        .from('restaurant_orders')
        .update(orderData)
        .eq('id', orderData['id']);
  }

  /// Get all orders for vendor
  static Future<List<Map<String, dynamic>>> getAllOrders(
      String vendorId) async {
    final response = await supabase
        .from('restaurant_orders')
        .select()
        .eq('vendor_id', vendorId)
        .order('created_at', ascending: false);
    return response;
  }

  /// Create order
  static Future<Map<String, dynamic>> createOrder(
      Map<String, dynamic> orderData) async {
    final response = await supabase
        .from('restaurant_orders')
        .insert(orderData)
        .select()
        .single();
    return response;
  }

  // ─── Coupon Management ───────────────────────────────────────

  /// Get all vendor coupons
  static Future<List<Map<String, dynamic>>> getAllVendorCoupons(
      String vendorId) async {
    final response = await supabase
        .from('coupons')
        .select()
        .eq('restaurant_id', vendorId)
        .eq('is_enabled', true)
        .eq('is_public', true)
        .gt('expires_at', 'now()');
    return response;
  }

  /// Get coupon by ID
  static Future<Map<String, dynamic>?> getCouponById(String couponId) async {
    final response =
        await supabase.from('coupons').select().eq('id', couponId).single();
    return response;
  }

  /// Create coupon
  static Future<Map<String, dynamic>> createCoupon(
      Map<String, dynamic> couponData) async {
    final response =
        await supabase.from('coupons').insert(couponData).select().single();
    return response;
  }

  /// Update coupon
  static Future<void> updateCoupon(Map<String, dynamic> couponData) async {
    await supabase
        .from('coupons')
        .update(couponData)
        .eq('id', couponData['id']);
  }

  /// Delete coupon
  static Future<void> deleteCoupon(String couponId) async {
    await supabase.from('coupons').delete().eq('id', couponId);
  }

  // ─── Wallet & Transactions ───────────────────────────────────

  /// Get wallet transactions
  static Future<List<Map<String, dynamic>>> getWalletTransactions(
      String userId) async {
    final response = await supabase
        .from('wallet')
        .select()
        .eq('user_id', userId)
        .order('date', ascending: false);
    return response;
  }

  /// Get filtered wallet transactions
  static Future<List<Map<String, dynamic>>> getFilteredWalletTransactions(
      String userId, DateTime startTime, DateTime endTime) async {
    final response = await supabase
        .from('wallet')
        .select()
        .eq('user_id', userId)
        .gte('date', startTime.toIso8601String())
        .lte('date', endTime.toIso8601String())
        .order('date', ascending: false);
    return response;
  }

  /// Create wallet transaction
  static Future<Map<String, dynamic>> createWalletTransaction(
      Map<String, dynamic> transactionData) async {
    final response =
        await supabase.from('wallet').insert(transactionData).select().single();
    return response;
  }

  /// Update user wallet amount
  static Future<void> updateUserWallet(String userId, double amount) async {
    final userProfile = await getUserProfile(userId);
    if (userProfile != null) {
      final currentWallet = (userProfile['wallet_amount'] ?? 0.0) as double;
      final newWalletAmount = currentWallet + amount;
      await updateUser({'id': userId, 'wallet_amount': newWalletAmount});
    }
  }

  // ─── Withdrawal Management ───────────────────────────────────

  /// Get withdrawal history
  static Future<List<Map<String, dynamic>>> getWithdrawalHistory(
      String vendorId) async {
    final response = await supabase
        .from('payouts')
        .select()
        .eq('vendor_id', vendorId)
        .order('paid_date', ascending: false);
    return response;
  }

  /// Update withdrawal
  static Future<void> updateWithdrawal(
      Map<String, dynamic> withdrawalData) async {
    await supabase
        .from('payouts')
        .update(withdrawalData)
        .eq('id', withdrawalData['id']);
  }

  /// Get withdrawal method
  static Future<Map<String, dynamic>?> getWithdrawalMethod(
      String userId) async {
    final response = await supabase
        .from('withdraw_method')
        .select()
        .eq('user_id', userId)
        .single();
    return response;
  }

  /// Create withdrawal method
  static Future<Map<String, dynamic>> createWithdrawalMethod(
      Map<String, dynamic> methodData) async {
    final response = await supabase
        .from('withdraw_method')
        .insert(methodData)
        .select()
        .single();
    return response;
  }

  // ─── Subscription Management ─────────────────────────────────

  /// Get all subscription plans
  static Future<List<Map<String, dynamic>>> getAllSubscriptionPlans() async {
    final response = await supabase
        .from('subscription_plans')
        .select()
        .eq('is_enable', true)
        .order('place', ascending: true);
    return response;
  }

  /// Get subscription plan by ID
  static Future<Map<String, dynamic>?> getSubscriptionPlanById(
      String planId) async {
    final response = await supabase
        .from('subscription_plans')
        .select()
        .eq('id', planId)
        .single();
    return response;
  }

  /// Create subscription plan
  static Future<Map<String, dynamic>> createSubscriptionPlan(
      Map<String, dynamic> planData) async {
    final response = await supabase
        .from('subscription_plans')
        .insert(planData)
        .select()
        .single();
    return response;
  }

  /// Update subscription plan
  static Future<void> updateSubscriptionPlan(
      Map<String, dynamic> planData) async {
    await supabase
        .from('subscription_plans')
        .update(planData)
        .eq('id', planData['id']);
  }

  /// Get subscription history
  static Future<List<Map<String, dynamic>>> getSubscriptionHistory(
      String userId) async {
    final response = await supabase
        .from('subscription_history')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return response;
  }

  /// Create subscription transaction
  static Future<Map<String, dynamic>> createSubscriptionTransaction(
      Map<String, dynamic> transactionData) async {
    final response = await supabase
        .from('subscription_history')
        .insert(transactionData)
        .select()
        .single();
    return response;
  }

  // ─── Employee Management ─────────────────────────────────────

  /// Get all employee roles
  static Future<List<Map<String, dynamic>>> getAllEmployeeRoles(String vendorId,
      {bool isActive = false}) async {
    var query = supabase
        .from('vendor_employee_roles')
        .select()
        .eq('vendor_id', vendorId);
    if (isActive) {
      query = query.eq('is_enable', true);
    }
    final response = await query;
    return response;
  }

  /// Get employee role by ID
  static Future<Map<String, dynamic>?> getEmployeeRoleById(
      String roleId) async {
    final response = await supabase
        .from('vendor_employee_roles')
        .select()
        .eq('id', roleId)
        .single();
    return response;
  }

  /// Create employee role
  static Future<Map<String, dynamic>> createEmployeeRole(
      Map<String, dynamic> roleData) async {
    final response = await supabase
        .from('vendor_employee_roles')
        .insert(roleData)
        .select()
        .single();
    return response;
  }

  /// Update employee role
  static Future<void> updateEmployeeRole(Map<String, dynamic> roleData) async {
    await supabase
        .from('vendor_employee_roles')
        .update(roleData)
        .eq('id', roleData['id']);
  }

  /// Delete employee role
  static Future<void> deleteEmployeeRole(String roleId) async {
    await supabase.from('vendor_employee_roles').delete().eq('id', roleId);
  }

  /// Get all employees
  static Future<List<Map<String, dynamic>>> getAllEmployees(
      String vendorId) async {
    final response = await supabase
        .from('users')
        .select()
        .eq('vendor_id', vendorId)
        .eq('role', 'employee')
        .order('created_at', ascending: false);
    return response;
  }

  // ─── Advertisement Management ────────────────────────────────

  /// Get advertisements by vendor ID
  static Future<List<Map<String, dynamic>>> getAdvertisements(
      String vendorId) async {
    final response = await supabase
        .from('advertisements')
        .select()
        .eq('vendor_id', vendorId)
        .order('created_at', ascending: false);
    return response;
  }

  /// Get advertisement by ID
  static Future<Map<String, dynamic>?> getAdvertisementById(
      String advertisementId) async {
    final response = await supabase
        .from('advertisements')
        .select()
        .eq('id', advertisementId)
        .single();
    return response;
  }

  /// Create advertisement
  static Future<Map<String, dynamic>> createAdvertisement(
      Map<String, dynamic> advertisementData) async {
    final response = await supabase
        .from('advertisements')
        .insert(advertisementData)
        .select()
        .single();
    return response;
  }

  /// Update advertisement
  static Future<void> updateAdvertisement(
      Map<String, dynamic> advertisementData) async {
    await supabase
        .from('advertisements')
        .update(advertisementData)
        .eq('id', advertisementData['id']);
  }

  /// Delete advertisement
  static Future<void> deleteAdvertisement(String advertisementId) async {
    await supabase.from('advertisements').delete().eq('id', advertisementId);
  }

  // ─── Dine-in Booking Management ──────────────────────────────

  /// Get dine-in bookings
  static Future<List<Map<String, dynamic>>> getDineInBookings(
      String vendorId, bool isUpcoming) async {
    var query =
        supabase.from('booked_table').select().eq('vendor_id', vendorId);
    if (isUpcoming) {
      query = query.gt('date', 'now()');
    } else {
      query = query.lt('date', 'now()');
    }
    final response = await query
        .order('date', ascending: false)
        .order('created_at', ascending: false);
    return response;
  }

  /// Create dine-in booking
  static Future<Map<String, dynamic>> createDineInBooking(
      Map<String, dynamic> bookingData) async {
    final response = await supabase
        .from('booked_table')
        .insert(bookingData)
        .select()
        .single();
    return response;
  }

  // ─── Chat & Conversation Management ──────────────────────────

  /// Add chat message
  static Future<Map<String, dynamic>> addChat(
      Map<String, dynamic> chatData) async {
    final response =
        await supabase.from('chat').insert(chatData).select().single();
    return response;
  }

  /// Add inbox
  static Future<Map<String, dynamic>> addInbox(
      Map<String, dynamic> inboxData) async {
    final response =
        await supabase.from('chat').insert(inboxData).select().single();
    return response;
  }

  // ─── Settings & Configuration ────────────────────────────────

  /// Get settings
  static Future<Map<String, dynamic>?> getSettings(String settingType) async {
    final response = await supabase
        .from('settings')
        .select()
        .eq('type', settingType)
        .single();
    return response;
  }

  /// Get all settings
  static Future<List<Map<String, dynamic>>> getAllSettings() async {
    final response = await supabase.from('settings').select();
    return response;
  }

  // ─── Utility Methods ─────────────────────────────────────────

  /// Check if user exists
  static Future<bool> userExists(String uid) async {
    final response =
        await supabase.from('users').select('id').eq('id', uid).single();
    return response != null;
  }

  /// Get vendor categories
  static Future<List<Map<String, dynamic>>> getVendorCategories() async {
    final response =
        await supabase.from('vendor_categories').select().eq('publish', true);
    return response;
  }

  /// Get attributes
  static Future<List<Map<String, dynamic>>> getAttributes() async {
    final response = await supabase.from('vendor_attributes').select();
    return response;
  }

  /// Get delivery charge
  static Future<Map<String, dynamic>?> getDeliveryCharge() async {
    final response = await supabase
        .from('settings')
        .select()
        .eq('type', 'DeliveryCharge')
        .single();
    return response;
  }

  /// Get documents
  static Future<List<Map<String, dynamic>>> getDocuments() async {
    final response = await supabase
        .from('documents')
        .select()
        .eq('type', 'restaurant')
        .eq('enable', true);
    return response;
  }

  /// Get driver documents
  static Future<Map<String, dynamic>?> getDriverDocuments(String userId) async {
    final response = await supabase
        .from('documents_verify')
        .select()
        .eq('user_id', userId)
        .single();
    return response;
  }

  /// Upload driver documents
  static Future<void> uploadDriverDocuments(
      String userId, List<Map<String, dynamic>> documents) async {
    await supabase.from('documents_verify').upsert({
      'user_id': userId,
      'type': 'restaurant',
      'documents': documents
    }).eq('user_id', userId);
  }

  /// Get reviews
  static Future<List<Map<String, dynamic>>> getOrderReviews(
      String vendorId) async {
    final response =
        await supabase.from('foods_review').select().eq('vendor_id', vendorId);
    return response;
  }

  /// Get available drivers
  static Future<List<Map<String, dynamic>>> getAvailableDrivers(
      String vendorId) async {
    final response = await supabase
        .from('users')
        .select()
        .eq('vendor_id', vendorId)
        .eq('role', 'driver')
        .eq('active', true)
        .eq('is_active', true)
        .order('created_at', ascending: false);
    return response;
  }

  /// Get all drivers
  static Future<List<Map<String, dynamic>>> getAllDrivers(
      String vendorId) async {
    final response = await supabase
        .from('users')
        .select()
        .eq('vendor_id', vendorId)
        .eq('role', 'driver')
        .order('created_at', ascending: false);
    return response;
  }

  /// Get notification content
  static Future<Map<String, dynamic>?> getNotificationContent(
      String type) async {
    final response = await supabase
        .from('dynamic_notification')
        .select()
        .eq('type', type)
        .single();
    return response;
  }

  /// Get email templates
  static Future<Map<String, dynamic>?> getEmailTemplates(String type) async {
    final response = await supabase
        .from('email_templates')
        .select()
        .eq('type', type)
        .single();
    return response;
  }

  /// Get admin commission
  static Future<Map<String, dynamic>?> getAdminCommission() async {
    final response = await supabase
        .from('settings')
        .select()
        .eq('type', 'AdminCommission')
        .single();
    return response;
  }

  /// Get onboarding data
  static Future<List<Map<String, dynamic>>> getOnboardingData() async {
    final response =
        await supabase.from('on_boarding').select().eq('type', 'restaurantApp');
    return response;
  }

  /// Get mail settings
  static Future<Map<String, dynamic>?> getMailSettings() async {
    final response = await supabase
        .from('settings')
        .select()
        .eq('type', 'emailSetting')
        .single();
    return response;
  }

  /// Get payment settings
  static Future<Map<String, dynamic>?> getPaymentSettings(
      String settingType) async {
    final response = await supabase
        .from('settings')
        .select()
        .eq('type', settingType)
        .single();
    return response;
  }

  /// Get current user ID
  static String getCurrentUid() {
    return supabase.auth.currentUser?.id ?? '';
  }

  /// Get vendor category by ID
  static Future<List<Map<String, dynamic>>> getVendorCategoryById() async {
    final response = await supabase
        .from('vendor_categories')
        .select()
        .order('title', ascending: true);

    return response;
  }

  /// Get zones
  static Future<List<Map<String, dynamic>>> getZone() async {
    final response =
        await supabase.from('zones').select().order('title', ascending: true);

    return response;
  }

  /// Get delivery settings
  static Future<Map<String, dynamic>?> getDelivery() async {
    final response = await supabase.from('delivery_charges').select().single();

    return response;
  }
}
