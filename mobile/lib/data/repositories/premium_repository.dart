import 'package:bepviet_mobile/data/models/subscription_model.dart';
import 'package:bepviet_mobile/data/models/family_model.dart';
import 'package:bepviet_mobile/data/models/analytics_model.dart';
import 'package:bepviet_mobile/data/sources/remote/premium_service.dart';

class PremiumRepository {
  final PremiumService _premiumService;

  PremiumRepository(this._premiumService);

  // Subscription methods
  Future<List<SubscriptionPlanModel>> getSubscriptionPlans(String token) async {
    return await _premiumService.getSubscriptionPlans(token);
  }

  Future<SubscriptionModel?> getUserSubscription(String token) async {
    return await _premiumService.getUserSubscription(token);
  }

  Future<SubscriptionModel> createSubscription(
    String token,
    CreateSubscriptionRequest request,
  ) async {
    return await _premiumService.createSubscription(token, request);
  }

  Future<void> cancelSubscription(String token, String subscriptionId) async {
    await _premiumService.cancelSubscription(token, subscriptionId);
  }

  Future<List<SubscriptionTransactionModel>> getUserTransactions(
    String token,
  ) async {
    return await _premiumService.getUserTransactions(token);
  }

  // Family methods
  Future<List<FamilyProfileModel>> getUserFamilyProfiles(String token) async {
    return await _premiumService.getUserFamilyProfiles(token);
  }

  Future<FamilyProfileModel> createFamilyProfile(
    String token,
    CreateFamilyProfileRequest request,
  ) async {
    return await _premiumService.createFamilyProfile(token, request);
  }

  Future<FamilyMemberModel> addFamilyMember(
    String token,
    String familyId,
    AddFamilyMemberRequest request,
  ) async {
    return await _premiumService.addFamilyMember(token, familyId, request);
  }

  Future<FamilyMemberModel> updateFamilyMember(
    String token,
    String memberId,
    UpdateFamilyMemberRequest request,
  ) async {
    return await _premiumService.updateFamilyMember(token, memberId, request);
  }

  Future<void> deleteFamilyMember(String token, String memberId) async {
    return await _premiumService.deleteFamilyMember(token, memberId);
  }

  // Analytics methods
  Future<UserAnalyticsModel> getUserAnalytics(String token) async {
    return await _premiumService.getUserAnalytics(token);
  }

  Future<SystemAnalyticsModel> getSystemAnalytics(String token) async {
    return await _premiumService.getSystemAnalytics(token);
  }
}
