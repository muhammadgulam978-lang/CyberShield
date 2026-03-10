package com.cybershield.threat.repository; // 👈 Yeh line folder structure se match karni chahiye

import com.cybershield.threat.model.ScanResult;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository // Spring ko batata hai ke yeh database se baat karne wali file hai
public interface ScanRepository extends JpaRepository<ScanResult, Long> {
    
    // Custom query: User ke scans ko time ke hisab se (latest first) dikhane ke liye
    List<ScanResult> findByUsernameOrderByScanTimestampDesc(String username);
}