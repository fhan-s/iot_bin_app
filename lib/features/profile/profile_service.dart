import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    final userData = await supabase
        .from('janitorial_staff')
        .select('full_name, role')
        .eq('id', user.id)
        .maybeSingle();

    if (userData == null) return null;

    return {...userData, 'email': user.email};
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  Future<void> updatePassword(String newPassword) async {
    await supabase.auth.updateUser(UserAttributes(password: newPassword));
  }
}
