import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ActiveRole { admin, cashier }

class ActiveRoleNotifier extends Notifier<ActiveRole> {
  @override
  ActiveRole build() {
    return ActiveRole.cashier;
  }

  void setRole(ActiveRole role) {
    state = role;
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('last_active_role', role.name);
    });
  }
}

final activeRoleProvider = NotifierProvider<ActiveRoleNotifier, ActiveRole>(
  ActiveRoleNotifier.new,
);
