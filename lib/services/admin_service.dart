class AdminService {
  // Email del administrador (del archivo .env)
  static const String adminEmail = 'fa8050386@gmail.com';

  /// Verifica si el email proporcionado es del administrador
  static bool isAdmin(String email) {
    return email.trim().toLowerCase() == adminEmail.toLowerCase();
  }

  /// Verifica si el usuario actual es administrador
  static bool isCurrentUserAdmin(String? currentEmail) {
    if (currentEmail == null) return false;
    return isAdmin(currentEmail);
  }
}
