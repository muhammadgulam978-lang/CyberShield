package com.cybershield.auth.service;

public interface AuthService {
    String login(String username, String rawPassword);
}