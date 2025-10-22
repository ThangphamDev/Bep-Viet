import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bepviet_mobile/data/models/subscription_model.dart';
import 'package:bepviet_mobile/data/models/family_model.dart';
import 'package:bepviet_mobile/data/models/analytics_model.dart';
import 'package:bepviet_mobile/data/repositories/premium_repository.dart';

// Events
abstract class PremiumEvent {
  const PremiumEvent();
}

class LoadPremiumData extends PremiumEvent {
  final String token;

  const LoadPremiumData(this.token);
}

class LoadUserSubscription extends PremiumEvent {
  final String token;

  const LoadUserSubscription(this.token);
}

class CreateSubscription extends PremiumEvent {
  final String token;
  final CreateSubscriptionRequest request;

  const CreateSubscription(this.token, this.request);
}

class CancelSubscription extends PremiumEvent {
  final String token;
  final String subscriptionId;

  const CancelSubscription(this.token, this.subscriptionId);
}

class LoadFamilyProfiles extends PremiumEvent {
  final String token;

  const LoadFamilyProfiles(this.token);
}

class CreateFamilyProfile extends PremiumEvent {
  final String token;
  final CreateFamilyProfileRequest request;

  const CreateFamilyProfile(this.token, this.request);
}

class AddFamilyMember extends PremiumEvent {
  final String token;
  final String familyId;
  final AddFamilyMemberRequest request;

  const AddFamilyMember(this.token, this.familyId, this.request);
}

class LoadUserAnalytics extends PremiumEvent {
  final String token;

  const LoadUserAnalytics(this.token);
}

// States
abstract class PremiumState {
  const PremiumState();
}

class PremiumInitial extends PremiumState {}

class PremiumLoading extends PremiumState {}

class PremiumLoaded extends PremiumState {
  final SubscriptionModel? subscription;
  final List<FamilyProfileModel> familyProfiles;
  final UserAnalyticsModel userAnalytics;
  final SystemAnalyticsModel systemAnalytics;

  const PremiumLoaded({
    this.subscription,
    required this.familyProfiles,
    required this.userAnalytics,
    required this.systemAnalytics,
  });

  PremiumLoaded copyWith({
    SubscriptionModel? subscription,
    List<FamilyProfileModel>? familyProfiles,
    UserAnalyticsModel? userAnalytics,
    SystemAnalyticsModel? systemAnalytics,
  }) {
    return PremiumLoaded(
      subscription: subscription ?? this.subscription,
      familyProfiles: familyProfiles ?? this.familyProfiles,
      userAnalytics: userAnalytics ?? this.userAnalytics,
      systemAnalytics: systemAnalytics ?? this.systemAnalytics,
    );
  }
}

class PremiumError extends PremiumState {
  final String message;

  const PremiumError(this.message);
}

// Cubit
class PremiumCubit extends Bloc<PremiumEvent, PremiumState> {
  final PremiumRepository _premiumRepository;

  PremiumCubit(this._premiumRepository) : super(PremiumInitial()) {
    on<LoadPremiumData>(_onLoadPremiumData);
    on<LoadUserSubscription>(_onLoadUserSubscription);
    on<CreateSubscription>(_onCreateSubscription);
    on<CancelSubscription>(_onCancelSubscription);
    on<LoadFamilyProfiles>(_onLoadFamilyProfiles);
    on<CreateFamilyProfile>(_onCreateFamilyProfile);
    on<AddFamilyMember>(_onAddFamilyMember);
    on<LoadUserAnalytics>(_onLoadUserAnalytics);
  }

  Future<void> _onLoadPremiumData(
    LoadPremiumData event,
    Emitter<PremiumState> emit,
  ) async {
    emit(PremiumLoading());
    try {
      final subscription = await _premiumRepository.getUserSubscription(
        event.token,
      );

      final familyProfiles = await _premiumRepository.getUserFamilyProfiles(
        event.token,
      );

      final userAnalytics = await _premiumRepository.getUserAnalytics(
        event.token,
      );

      // System analytics might only be for admin, handle gracefully if not available
      SystemAnalyticsModel? systemAnalytics;
      try {
        systemAnalytics = await _premiumRepository.getSystemAnalytics(
          event.token,
        );
      } catch (e) {
        // Ignore system analytics errors (non-admin users)
      }

      emit(
        PremiumLoaded(
          subscription: subscription,
          familyProfiles: familyProfiles,
          userAnalytics: userAnalytics,
          systemAnalytics: systemAnalytics ?? const SystemAnalyticsModel(),
        ),
      );
    } catch (e) {
      emit(PremiumError(e.toString()));
    }
  }

  Future<void> _onLoadUserSubscription(
    LoadUserSubscription event,
    Emitter<PremiumState> emit,
  ) async {
    try {
      final subscription = await _premiumRepository.getUserSubscription(
        event.token,
      );

      if (state is PremiumLoaded) {
        final currentState = state as PremiumLoaded;
        emit(currentState.copyWith(subscription: subscription));
      } else {
        emit(
          PremiumLoaded(
            subscription: subscription,
            familyProfiles: const [],
            userAnalytics: const UserAnalyticsModel(),
            systemAnalytics: const SystemAnalyticsModel(),
          ),
        );
      }
    } catch (e) {
      emit(PremiumError(e.toString()));
    }
  }

  Future<void> _onCreateSubscription(
    CreateSubscription event,
    Emitter<PremiumState> emit,
  ) async {
    try {
      final subscription = await _premiumRepository.createSubscription(
        event.token,
        event.request,
      );

      if (state is PremiumLoaded) {
        final currentState = state as PremiumLoaded;
        emit(currentState.copyWith(subscription: subscription));
      }
    } catch (e) {
      emit(PremiumError(e.toString()));
    }
  }

  Future<void> _onCancelSubscription(
    CancelSubscription event,
    Emitter<PremiumState> emit,
  ) async {
    try {
      await _premiumRepository.cancelSubscription(
        event.token,
        event.subscriptionId,
      );

      if (state is PremiumLoaded) {
        final currentState = state as PremiumLoaded;
        emit(currentState.copyWith(subscription: null));
      }
    } catch (e) {
      emit(PremiumError(e.toString()));
    }
  }

  Future<void> _onLoadFamilyProfiles(
    LoadFamilyProfiles event,
    Emitter<PremiumState> emit,
  ) async {
    try {
      final familyProfiles = await _premiumRepository.getUserFamilyProfiles(
        event.token,
      );

      if (state is PremiumLoaded) {
        final currentState = state as PremiumLoaded;
        emit(currentState.copyWith(familyProfiles: familyProfiles));
      } else {
        emit(
          PremiumLoaded(
            subscription: null,
            familyProfiles: familyProfiles,
            userAnalytics: const UserAnalyticsModel(),
            systemAnalytics: const SystemAnalyticsModel(),
          ),
        );
      }
    } catch (e) {
      emit(PremiumError(e.toString()));
    }
  }

  Future<void> _onCreateFamilyProfile(
    CreateFamilyProfile event,
    Emitter<PremiumState> emit,
  ) async {
    try {
      final newProfile = await _premiumRepository.createFamilyProfile(
        event.token,
        event.request,
      );

      if (state is PremiumLoaded) {
        final currentState = state as PremiumLoaded;
        final updatedProfiles = [...currentState.familyProfiles, newProfile];
        emit(currentState.copyWith(familyProfiles: updatedProfiles));
      }
    } catch (e) {
      emit(PremiumError(e.toString()));
    }
  }

  Future<void> _onAddFamilyMember(
    AddFamilyMember event,
    Emitter<PremiumState> emit,
  ) async {
    try {
      final newMember = await _premiumRepository.addFamilyMember(
        event.token,
        event.familyId,
        event.request,
      );

      if (state is PremiumLoaded) {
        final currentState = state as PremiumLoaded;
        final updatedProfiles = currentState.familyProfiles.map((profile) {
          if (profile.id == event.familyId) {
            return profile.copyWith(members: [...profile.members, newMember]);
          }
          return profile;
        }).toList();

        emit(currentState.copyWith(familyProfiles: updatedProfiles));
      }
    } catch (e) {
      emit(PremiumError(e.toString()));
    }
  }

  Future<void> _onLoadUserAnalytics(
    LoadUserAnalytics event,
    Emitter<PremiumState> emit,
  ) async {
    try {
      final userAnalytics = await _premiumRepository.getUserAnalytics(
        event.token,
      );

      if (state is PremiumLoaded) {
        final currentState = state as PremiumLoaded;
        emit(currentState.copyWith(userAnalytics: userAnalytics));
      } else {
        emit(
          PremiumLoaded(
            subscription: null,
            familyProfiles: const [],
            userAnalytics: userAnalytics,
            systemAnalytics: const SystemAnalyticsModel(),
          ),
        );
      }
    } catch (e) {
      emit(PremiumError(e.toString()));
    }
  }
}
