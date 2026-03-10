package com.cybershield.auth.controller;

import java.util.Map;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.cybershield.auth.model.LoginRequest;
import com.cybershield.auth.model.User;
import com.cybershield.auth.repository.UserRepository;
import com.cybershield.auth.security.JwtUtils;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*")
public class AuthController {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private JwtUtils jwtUtils;

   @PostMapping("/login")
public ResponseEntity<?> loginUser(@RequestBody LoginRequest loginRequest) {
    System.out.println("===> 🛡️ CYBERSHIELD LOGIN ATTEMPT <===");
    System.out.println("User Input: [" + loginRequest.getUsername() + "]");

    // 🚀 EMERGENCY BYPASS: Agar DB dhoka de raha hai toh ye kaam karega
    if ("tester".equals(loginRequest.getUsername()) && "password123".equals(loginRequest.getPassword())) {
        String token = jwtUtils.generateToken("tester");
        System.out.println("✅ EMERGENCY LOGIN SUCCESS: Bypass Applied");
        return ResponseEntity.ok(Map.of("token", token));
    }

    // Normal DB logic (as fallback)
    Optional<User> userOpt = userRepository.findByUsername(loginRequest.getUsername());
    if (userOpt.isPresent()) {
        User user = userOpt.get();
        if (passwordEncoder.matches(loginRequest.getPassword(), user.getPassword())) {
            String token = jwtUtils.generateToken(loginRequest.getUsername());
            return ResponseEntity.ok(Map.of("token", token));
        }
    }

    System.out.println("❌ LOGIN FAILED for: " + loginRequest.getUsername());
    return ResponseEntity.status(401).body(Map.of("error", "Invalid credentials!"));
}
    @PostMapping("/register")
    public ResponseEntity<?> registerUser(@RequestBody User user) {
        user.setPassword(passwordEncoder.encode(user.getPassword()));
        userRepository.save(user);
        return ResponseEntity.ok(Map.of("message", "User registered successfully!"));
    }
}