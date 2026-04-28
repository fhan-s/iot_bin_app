import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient supabase = Supabase.instance.client;

  Stream<AuthState> get authStateChanges => supabase.auth.onAuthStateChange;

  Session? get currentSession => supabase.auth.currentSession;

  User? get currentUser => supabase.auth.currentUser;

  Future<AuthResponse> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    return await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<String?> getUserRole() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      return null;
    }
    final userRole = await Supabase.instance.client
        .from('janitorial_staff')
        .select('role')
        .eq('id', user.id)
        .maybeSingle();
    return userRole?['role'] as String?;
  }
}
