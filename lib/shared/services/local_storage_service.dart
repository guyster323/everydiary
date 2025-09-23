import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/subscription_model.dart';

/// 로컬 저장소 서비스
///
/// 구독 정보를 로컬에 저장하고 관리하는 서비스입니다.
class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  static const String _subscriptionKey = 'subscription_info';
  static const String _purchaseHistoryKey = 'purchase_history';
  static const String _promoCodeKey = 'promo_code';
  static const String _lastSyncKey = 'last_sync_time';

  /// 구독 정보 저장
  Future<void> saveSubscriptionInfo(SubscriptionModel subscription) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final subscriptionJson = subscription.toJson();
      await prefs.setString(_subscriptionKey, jsonEncode(subscriptionJson));
      debugPrint('Subscription info saved: ${subscription.productId}');
    } catch (e) {
      debugPrint('Error saving subscription info: $e');
    }
  }

  /// 구독 정보 로드
  Future<SubscriptionModel?> loadSubscriptionInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final subscriptionJsonString = prefs.getString(_subscriptionKey);

      if (subscriptionJsonString == null) {
        return null;
      }

      final subscriptionJson =
          jsonDecode(subscriptionJsonString) as Map<String, dynamic>;
      return SubscriptionModel.fromJson(subscriptionJson);
    } catch (e) {
      debugPrint('Error loading subscription info: $e');
      return null;
    }
  }

  /// 구독 정보 삭제
  Future<void> clearSubscriptionInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_subscriptionKey);
      debugPrint('Subscription info cleared');
    } catch (e) {
      debugPrint('Error clearing subscription info: $e');
    }
  }

  /// 구매 기록 저장
  Future<void> savePurchaseHistory(List<PurchaseRecord> purchases) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final purchasesJson = purchases.map((p) => p.toJson()).toList();
      await prefs.setString(_purchaseHistoryKey, jsonEncode(purchasesJson));
      debugPrint('Purchase history saved: ${purchases.length} records');
    } catch (e) {
      debugPrint('Error saving purchase history: $e');
    }
  }

  /// 구매 기록 로드
  Future<List<PurchaseRecord>> loadPurchaseHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final purchasesJsonString = prefs.getString(_purchaseHistoryKey);

      if (purchasesJsonString == null) {
        return [];
      }

      final purchasesJson = jsonDecode(purchasesJsonString) as List<dynamic>;
      return purchasesJson
          .map((json) => PurchaseRecord.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error loading purchase history: $e');
      return [];
    }
  }

  /// 구매 기록에 추가
  Future<void> addPurchaseRecord(PurchaseRecord purchase) async {
    try {
      final existingPurchases = await loadPurchaseHistory();
      existingPurchases.add(purchase);
      await savePurchaseHistory(existingPurchases);
      debugPrint('Purchase record added: ${purchase.productId}');
    } catch (e) {
      debugPrint('Error adding purchase record: $e');
    }
  }

  /// 구매 기록 삭제
  Future<void> clearPurchaseHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('purchase_history');
  }

  /// 프로모션 코드 저장
  Future<void> savePromoCode(String promoCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_promoCodeKey, promoCode);
      debugPrint('Promo code saved: $promoCode');
    } catch (e) {
      debugPrint('Error saving promo code: $e');
    }
  }

  /// 프로모션 코드 로드
  Future<String?> loadPromoCode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_promoCodeKey);
    } catch (e) {
      debugPrint('Error loading promo code: $e');
      return null;
    }
  }

  /// 프로모션 코드 삭제
  Future<void> clearPromoCode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_promoCodeKey);
      debugPrint('Promo code cleared');
    } catch (e) {
      debugPrint('Error clearing promo code: $e');
    }
  }

  /// 마지막 동기화 시간 저장
  Future<void> saveLastSyncTime(DateTime syncTime) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_lastSyncKey, syncTime.millisecondsSinceEpoch);
      debugPrint('Last sync time saved: $syncTime');
    } catch (e) {
      debugPrint('Error saving last sync time: $e');
    }
  }

  /// 마지막 동기화 시간 로드
  Future<DateTime?> loadLastSyncTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final syncTimeMs = prefs.getInt(_lastSyncKey);
      if (syncTimeMs == null) return null;
      return DateTime.fromMillisecondsSinceEpoch(syncTimeMs);
    } catch (e) {
      debugPrint('Error loading last sync time: $e');
      return null;
    }
  }

  /// 동기화 필요 여부 확인
  Future<bool> needsSync() async {
    try {
      final lastSync = await loadLastSyncTime();
      if (lastSync == null) return true;

      // 24시간마다 동기화
      final now = DateTime.now();
      return now.difference(lastSync).inHours >= 24;
    } catch (e) {
      debugPrint('Error checking sync status: $e');
      return true;
    }
  }

  /// 모든 데이터 삭제
  Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_subscriptionKey);
      await prefs.remove(_purchaseHistoryKey);
      await prefs.remove(_promoCodeKey);
      await prefs.remove(_lastSyncKey);
      debugPrint('All subscription data cleared');
    } catch (e) {
      debugPrint('Error clearing all data: $e');
    }
  }

  /// 저장소 상태 확인
  Future<StorageStatus> getStorageStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasSubscription = prefs.containsKey(_subscriptionKey);
      final hasPurchaseHistory = prefs.containsKey(_purchaseHistoryKey);
      final hasPromoCode = prefs.containsKey(_promoCodeKey);
      final lastSync = await loadLastSyncTime();

      return StorageStatus(
        hasSubscription: hasSubscription,
        hasPurchaseHistory: hasPurchaseHistory,
        hasPromoCode: hasPromoCode,
        lastSyncTime: lastSync,
      );
    } catch (e) {
      debugPrint('Error getting storage status: $e');
      return const StorageStatus(
        hasSubscription: false,
        hasPurchaseHistory: false,
        hasPromoCode: false,
        lastSyncTime: null,
      );
    }
  }
}

/// 구매 기록 모델
class PurchaseRecord {
  final String id;
  final String productId;
  final String transactionId;
  final DateTime purchaseTime;
  final double price;
  final String currency;
  final String status;
  final String? promoCode;

  const PurchaseRecord({
    required this.id,
    required this.productId,
    required this.transactionId,
    required this.purchaseTime,
    required this.price,
    required this.currency,
    required this.status,
    this.promoCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'transactionId': transactionId,
      'purchaseTime': purchaseTime.millisecondsSinceEpoch,
      'price': price,
      'currency': currency,
      'status': status,
      'promoCode': promoCode,
    };
  }

  factory PurchaseRecord.fromJson(Map<String, dynamic> json) {
    return PurchaseRecord(
      id: json['id'] as String,
      productId: json['productId'] as String,
      transactionId: json['transactionId'] as String,
      purchaseTime: DateTime.fromMillisecondsSinceEpoch(
        json['purchaseTime'] as int,
      ),
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String,
      status: json['status'] as String,
      promoCode: json['promoCode'] as String?,
    );
  }
}

/// 저장소 상태 모델
class StorageStatus {
  final bool hasSubscription;
  final bool hasPurchaseHistory;
  final bool hasPromoCode;
  final DateTime? lastSyncTime;

  const StorageStatus({
    required this.hasSubscription,
    required this.hasPurchaseHistory,
    required this.hasPromoCode,
    required this.lastSyncTime,
  });

  @override
  String toString() {
    return 'StorageStatus(hasSubscription: $hasSubscription, hasPurchaseHistory: $hasPurchaseHistory, hasPromoCode: $hasPromoCode, lastSyncTime: $lastSyncTime)';
  }
}
