package com.example.DACN.repository;

import com.example.DACN.entity.Contract;
import com.example.DACN.entity.Room;
import com.example.DACN.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface ContractRepository extends JpaRepository<Contract, Long> {

    List<Contract> findByRoom_Owner_Id(Long ownerId);

    List<Contract> findByTenant(User tenant);

    List<Contract> findByOwner(User owner);

    Optional<Contract> findFirstByRoomAndStatus(Room room, String status);
}