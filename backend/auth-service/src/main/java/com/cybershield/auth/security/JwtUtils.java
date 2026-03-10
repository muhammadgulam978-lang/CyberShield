package com.cybershield.auth.security; // Threat service mein package name threat wala hoga

import java.nio.charset.StandardCharsets;
import java.security.Key;
import java.util.Date;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import jakarta.annotation.PostConstruct;

@Component
public class JwtUtils {

    @Value("${jwt.secret:CyberShield_Default_Backup_Key_123456789}") // Default key backup ke liye
    private String secretKey;

    private final int jwtExpirationMs = 86400000;

    @PostConstruct
    public void init() {
        System.out.println("🛡️ JWT Secret Loaded: " + secretKey.substring(0, 5) + "...");
    }

    public String generateToken(String username) {
        Key key = Keys.hmacShaKeyFor(secretKey.getBytes(StandardCharsets.UTF_8));

        return Jwts.builder()
                .setSubject(username)
                .setIssuedAt(new Date())
                .setExpiration(new Date((new Date()).getTime() + jwtExpirationMs))
                .signWith(key)
                .compact();
    }

    // Threat Service ke liye validate token method bhi zaroori hai
    public String getUsernameFromToken(String token) {
        Key key = Keys.hmacShaKeyFor(secretKey.getBytes(StandardCharsets.UTF_8));
        return Jwts.parserBuilder()
                .setSigningKey(key)
                .build()
                .parseClaimsJws(token)
                .getBody()
                .getSubject();
    }
}