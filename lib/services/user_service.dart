part of 'services.dart';

class UserService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Creates a user profile (call this after successful auth registration)
  static Future<UserModel> createUserProfile({
    required String userId,
    String? name,
    String? photoProfileUrl,
  }) async {
    try {
      // Get the current user's email (no admin privileges needed)
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null || currentUser.id != userId) {
        throw DatabaseException('Not authenticated or user mismatch');
      }

      final response =
          await _supabase
              .from('user_profiles')
              .insert({
                'user_id': userId,
                'name': name,
                'photo_profile_url': photoProfileUrl,
              })
              .select()
              .single();

      return UserModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw DatabaseException('Failed to create profile: ${e.message}');
    } catch (e) {
      throw DatabaseException('Unexpected error: ${e.toString()}');
    }
  }

  /// Gets the current user's profile
  static Future<UserModel> getCurrentUserProfile() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw DatabaseException('Not authenticated');

      final response =
          await _supabase
              .from('user_profiles')
              .select()
              .eq('user_id', userId)
              .single();

      return UserModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw DatabaseException('Profile not found: ${e.message}');
    } catch (e) {
      throw DatabaseException('Failed to fetch profile: ${e.toString()}');
    }
  }

  /// Updates user profile
  static Future<UserModel> updateProfile({
    String? name,
    String? photoProfileUrl,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw DatabaseException('Not authenticated');

      final response =
          await _supabase
              .from('user_profiles')
              .update({'name': name, 'photo_profile_url': photoProfileUrl})
              .eq('user_id', userId)
              .select()
              .single();

      return UserModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw DatabaseException('Update failed: ${e.message}');
    } catch (e) {
      throw DatabaseException('Unexpected error: ${e.toString()}');
    }
  }

  /// get current user
  static Future<UserModel?> getCurrentUser() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final response =
          await _supabase
              .from('user_profiles')
              .select()
              .eq('user_id', userId)
              .single();

      return UserModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw DatabaseException('Failed to fetch user: ${e.message}');
    } catch (e) {
      throw DatabaseException('Unexpected error: ${e.toString()}');
    }
  }
}

class DatabaseException implements Exception {
  final String message;

  DatabaseException(this.message);

  @override
  String toString() => 'DatabaseException: $message';
}
