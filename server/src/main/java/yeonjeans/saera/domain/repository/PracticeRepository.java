package yeonjeans.saera.domain.repository;

import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import yeonjeans.saera.domain.entity.Practice;
import yeonjeans.saera.domain.entity.example.ReferenceType;
import yeonjeans.saera.domain.entity.member.Member;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Date;
import java.util.List;
import java.util.Optional;

public interface PracticeRepository extends JpaRepository<Practice, Long> {
    Optional<Practice> findFirstByMemberOrderByModifiedDateDesc(Member member);

    Optional<Practice> findByMemberAndTypeAndFk(Member member, ReferenceType type, Long fk);

    @Query("SELECT p.fk " +
            "FROM Practice p " +
            "WHERE p.type = :type " +
            "AND FUNCTION('DATE', p.modifiedDate) = CURRENT_DATE " +
            "GROUP BY p.fk " +
            "ORDER BY SUM(p.count) DESC " )
    List<Long> findTop5ByCount(@Param("type")ReferenceType type, Pageable pageable);

    @Query("SELECT p.fk " +
            "FROM Practice p " +
            "WHERE p.type = :type " +
            "AND FUNCTION('DATE', p.modifiedDate) < CURRENT_DATE " +
            "GROUP BY p.fk " +
            "ORDER BY SUM(p.count) DESC " )
    List<Long> findRestTop5ByCount(@Param("type")ReferenceType type, Pageable pageable);
}
