part of 'services.dart';

class AuthService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Signs in with email and password
  /// Returns [AuthResponse] on success
  /// Throws [AuthException] on failure
  static Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } on AuthException catch (e) {
      throw AuthException('Login failed: ${e.message}');
    } catch (e) {
      throw AuthException('Unexpected login error: ${e.toString()}');
    }
  }

  /// Signs up with email and password
  /// Returns [AuthResponse] on success
  /// Throws [AuthException] on failure
  static Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    Map<String, dynamic>? userMetadata,
  }) async {
    try {
      return await _supabase.auth.signUp(
        email: email,
        password: password,
        data: userMetadata,
      );
    } on AuthException catch (e) {
      throw AuthException('Registration failed: ${e.message}');
    } catch (e) {
      throw AuthException('Unexpected registration error: ${e.toString()}');
    }
  }

  /// Signs out the current user
  /// Throws [AuthException] on failure
  static Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } on AuthException catch (e) {
      throw AuthException('Sign out failed: ${e.message}');
    } catch (e) {
      throw AuthException('Unexpected sign out error: ${e.toString()}');
    }
  }

  /// Gets the current authenticated user
  /// Returns [User] if authenticated, null otherwise
  static User? get currentUser => _supabase.auth.currentUser;

  /// Checks if a user is currently authenticated
  static bool get isAuthenticated => _supabase.auth.currentUser != null;

  /// Gets the current session
  /// Returns [Session] if authenticated, null otherwise
  static Session? get currentSession => _supabase.auth.currentSession;

  /// Sends a password reset email
  /// Throws [AuthException] on failure
  static Future<void> resetPasswordForEmail(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw AuthException('Password reset failed: ${e.message}');
    } catch (e) {
      throw AuthException('Unexpected password reset error: ${e.toString()}');
    }
  }

  /// Updates user's password
  /// Throws [AuthException] on failure
  static Future<void> updateUserPassword(String newPassword) async {
    try {
      await _supabase.auth.updateUser(UserAttributes(password: newPassword));
    } on AuthException catch (e) {
      throw AuthException('Password update failed: ${e.message}');
    } catch (e) {
      throw AuthException('Unexpected password update error: ${e.toString()}');
    }
  }

  /// Refreshes the current session
  /// Throws [AuthException] on failure
  static Future<AuthResponse> refreshSession() async {
    try {
      return await _supabase.auth.refreshSession();
    } on AuthException catch (e) {
      throw AuthException('Session refresh failed: ${e.message}');
    } catch (e) {
      throw AuthException('Unexpected session refresh error: ${e.toString()}');
    }
  }

  /// Gets the current user's JWT token
  /// Returns null if not authenticated
  static String? get currentUserToken => currentSession?.accessToken;
}
