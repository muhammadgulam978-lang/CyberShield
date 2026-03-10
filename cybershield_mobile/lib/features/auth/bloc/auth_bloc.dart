import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../repository/auth_repository.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    
    // 🛡️ Login Handle
    on<LoginRequested>((event, emit) async {
      // Basic validation: Khali fields par request mat bhejo
      if (event.username.trim().isEmpty || event.password.trim().isEmpty) {
        emit(AuthFailure("Username aur Password zaroori hain!"));
        return;
      }

      emit(AuthLoading());
      try {
        final success = await authRepository.login(event.username, event.password);
        if (success) {
          emit(AuthSuccess("Welcome to CyberShield!"));
        } else {
          emit(AuthFailure("Ghalat Username ya Password!"));
        }
      } catch (e) {
        emit(AuthFailure("Server se rabta nahi ho pa raha: ${e.toString()}"));
      }
    });

    // 🚪 Logout Handle (AB YEH TOKEN DELETE KAREGA)
    on<LogoutRequested>((event, emit) async {
      await authRepository.logout(); // Storage saaf karo
      emit(AuthInitial()); // UI ko reset karo
    });
  }
}