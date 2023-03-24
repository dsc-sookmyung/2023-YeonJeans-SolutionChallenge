package yeonjeans.saera.domain.repository.custom;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import yeonjeans.saera.domain.entity.custom.CTag;
import yeonjeans.saera.domain.entity.member.Member;

import java.util.List;
import java.util.Optional;

public interface CTagRepository extends JpaRepository<CTag, Long> {

    boolean existsByMemberAndName(Member member, String name);
    Optional<CTag> findByMemberAndName(Member member, String name);

    @Query("SELECT t " +
            "FROM CTag t " +
            "WHERE t.member = :member " +
            "AND t NOT IN (SELECT ct.tag FROM CustomCtag ct)")
    List<CTag> findAllByMemberNotInCustomCTag(@Param("member")Member member);

    List<CTag> findAllByMemberId(Long memberId);
}
