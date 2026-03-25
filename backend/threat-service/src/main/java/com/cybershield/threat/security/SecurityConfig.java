// package com.cybershield.threat.security;

// import org.springframework.beans.factory.annotation.Autowired;
// import org.springframework.context.annotation.Bean;
// import org.springframework.context.annotation.Configuration;
// import org.springframework.security.config.annotation.web.builders.HttpSecurity;
// import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
// import org.springframework.security.config.http.SessionCreationPolicy;
// import org.springframework.security.web.SecurityFilterChain;
// import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
// import java.util.Arrays;
// import org.springframework.web.cors.CorsConfiguration;
// import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
// import org.springframework.web.cors.CorsConfigurationSource;

// @Configuration
// @EnableWebSecurity
// public class SecurityConfig {

//     @Autowired
//     private JwtAuthenticationFilter jwtAuthenticationFilter;

//     @Bean
//     public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
//         http
//             .csrf(csrf -> csrf.disable()) 
//             .cors(cors -> cors.configurationSource(corsConfigurationSource()))
//             .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
//             .authorizeHttpRequests(auth -> auth
//                 // 1. Public Endpoints (Swagger & Auth)
//                 .requestMatchers(
//                     "/v3/api-docs/**", 
//                     "/swagger-ui/**", 
//                     "/swagger-ui.html",
//                     "/api/auth/**"
//                 ).permitAll()
                
//                 // 2. 🛡️ DATA FLOW FIX: Poori tarah open kar diya hai
//                 // Ab Flutter app ko 403 Forbidden error nahi aayega
//                 .requestMatchers("/api/threat/**").permitAll() 
                
//                 .anyRequest().authenticated() 
//             )
//             .addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class);

//         return http.build();
//     }

//     @Bean
//     public CorsConfigurationSource corsConfigurationSource() {
//         CorsConfiguration config = new CorsConfiguration();
//         config.setAllowCredentials(true);
//         config.setAllowedOriginPatterns(Arrays.asList("*")); 
        
//         // 🔥 UPDATE: Added "Content-Disposition" and "ExposedHeaders" for PDF Download
//         config.setAllowedHeaders(Arrays.asList("Origin", "Content-Type", "Accept", "Authorization", "X-Requested-With"));
//         config.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "DELETE", "OPTIONS"));
        
//         // Ye line browser ko batati hai ke PDF ka filename (Content-Disposition) parhna allowed hai
//         config.setExposedHeaders(Arrays.asList("Content-Disposition", "Authorization"));
        
//         UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
//         source.registerCorsConfiguration("/**", config);
//         return source;
//     }
// }


// package com.cybershield.threat.security;

// import org.springframework.beans.factory.annotation.Autowired;
// import org.springframework.context.annotation.Bean;
// import org.springframework.context.annotation.Configuration;
// import org.springframework.security.config.annotation.web.builders.HttpSecurity;
// import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
// import org.springframework.security.config.http.SessionCreationPolicy;
// import org.springframework.security.web.SecurityFilterChain;
// import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
// import java.util.Arrays;
// import org.springframework.web.cors.CorsConfiguration;
// import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
// import org.springframework.web.cors.CorsConfigurationSource;

// @Configuration
// @EnableWebSecurity
// public class SecurityConfig {

//     @Autowired
//     private JwtAuthenticationFilter jwtAuthenticationFilter;

//     @Bean
//     public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
//         http
//             .csrf(csrf -> csrf.disable()) 
//             .cors(cors -> cors.configurationSource(corsConfigurationSource()))
//             .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
//             .authorizeHttpRequests(auth -> auth
//                 .requestMatchers(
//                     "/v3/api-docs/**", 
//                     "/swagger-ui/**", 
//                     "/swagger-ui.html",
//                     "/api/auth/**"
//                 ).permitAll()
                
//                 // ✅ FIXED: Endpoints are now protected. Must have a valid JWT.
//                 .requestMatchers("/api/threat/**").authenticated() 
                
//                 .anyRequest().authenticated() 
//             )
//             .addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class);

//         return http.build();
//     }

//     @Bean
//     public CorsConfigurationSource corsConfigurationSource() {
//         CorsConfiguration config = new CorsConfiguration();
//         config.setAllowCredentials(true);
//         config.setAllowedOriginPatterns(Arrays.asList("*")); 
//         config.setAllowedHeaders(Arrays.asList("Origin", "Content-Type", "Accept", "Authorization", "X-Requested-With"));
//         config.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "DELETE", "OPTIONS"));
//         config.setExposedHeaders(Arrays.asList("Content-Disposition", "Authorization"));
        
//         UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
//         source.registerCorsConfiguration("/**", config);
//         return source;
//     }
// }


package com.cybershield.threat.security;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import java.util.Arrays;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
import org.springframework.web.cors.CorsConfigurationSource;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Autowired
    private JwtAuthenticationFilter jwtAuthenticationFilter;

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .csrf(csrf -> csrf.disable()) 
            .cors(cors -> cors.configurationSource(corsConfigurationSource()))
            .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .authorizeHttpRequests(auth -> auth
                .requestMatchers(
                    "/v3/api-docs/**", 
                    "/swagger-ui/**", 
                    "/swagger-ui.html",
                    "/api/auth/**",
                    "/api/threat/download-report/**" // ✅ PDF Download ko allow kar diya (New Line)
                ).permitAll()
                
                // ✅ Baaki endpoints protected rahengy, valid JWT lazmi hai
                .requestMatchers("/api/threat/**").authenticated() 
                
                .anyRequest().authenticated() 
            )
            .addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration config = new CorsConfiguration();
        config.setAllowCredentials(true);
        config.setAllowedOriginPatterns(Arrays.asList("*")); 
        config.setAllowedHeaders(Arrays.asList("Origin", "Content-Type", "Accept", "Authorization", "X-Requested-With"));
        config.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "DELETE", "OPTIONS"));
        config.setExposedHeaders(Arrays.asList("Content-Disposition", "Authorization"));
        
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", config);
        return source;
    }
}