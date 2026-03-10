package com.cybershield.auth.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import com.cybershield.auth.model.User;
import com.cybershield.auth.repository.UserRepository;
import com.cybershield.auth.security.JwtUtils;

@Service
public class AuthServiceImpl implements AuthService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private JwtUtils jwtUtil;

    @Override
    public String login(String username, String rawPassword) {
        System.out.println("===> 🛡️ CYBERSHIELD LOGIN ATTEMPT <===");
        System.out.println("Username: " + username);

        // 1. User fetch karein database se
        User user = userRepository.findByUsername(username)
            .orElseThrow(() -> new RuntimeException("USER_NOT_FOUND"));

        // 🔍 DEBUG: Yeh lines aapko terminal mein asliyat dikhayengi
        System.out.println("Flutter Raw Password: " + rawPassword);
        System.out.println("Database Hashed Password: " + user.getPassword());

        // 2. BCrypt matching (Zaroori hai kyunki DB mein hash hai)
        boolean isMatch = passwordEncoder.matches(rawPassword, user.getPassword());
        System.out.println("BCrypt Match Result: " + isMatch);

        if (isMatch) {
            String token = jwtUtil.generateToken(username);
            System.out.println("✅ SUCCESS: JWT Token Created.");
            return token;
        } else {
            System.out.println("❌ FAILURE: Password does not match!");
            // Hum "Invalid credentials!" bhej rahe hain taaki Flutter wahi dikhaye
            return "Invalid credentials!"; 
        }
    }
}