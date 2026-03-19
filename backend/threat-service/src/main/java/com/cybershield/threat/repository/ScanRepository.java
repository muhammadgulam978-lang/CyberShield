package com.cybershield.threat.repository;

import com.cybershield.threat.model.ScanResult;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface ScanRepository extends JpaRepository<ScanResult, Long> {
    
    // Latest history for a specific user
    List<ScanResult> findByUsernameOrderByScanTimestampDesc(String username);
}