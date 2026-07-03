import 'package:campus_api/campus_api.dart';
import 'package:campusconnect/features/auth/presentation/auth_controller.dart';

/// Auth controller seeded with a fixed state — no storage/network.
class FakeAuthController extends AuthController {
  FakeAuthController(this.initial);

  final AuthState initial;

  @override
  AuthState build() => initial;

  @override
  Future<void> logOut() async {
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

UserMeResponse testUser({String displayName = 'Test Student'}) =>
    UserMeResponse(
      (b) => b
        ..id = 'u-1'
        ..email = 'test@campus.edu'
        ..displayName = displayName
        ..ratingCount = 3
        ..reputationScore = 4.2
        ..role = UserRole.student
        ..createdAt = DateTime.utc(2026),
    );

AuthState authedState() =>
    AuthState(status: AuthStatus.authenticated, user: testUser());

const anonState = AuthState(status: AuthStatus.unauthenticated);
