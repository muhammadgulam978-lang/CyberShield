abstract class AuthEvent {}

// Jab user login button dabaye
class LoginRequested extends AuthEvent {
  final String username;
  final String password;

  LoginRequested(this.username, this.password);
}

// Logout ke liye
class LogoutRequested extends AuthEvent {}