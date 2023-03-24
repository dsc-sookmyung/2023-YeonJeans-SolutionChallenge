package yeonjeans.saera.domain.repository.member;

import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import yeonjeans.saera.domain.entity.member.Member;
import yeonjeans.saera.domain.entity.member.Platform;

import java.util.Optional;

public interface MemberRepository extends JpaRepository<Member, Long> {

//    @Query("select m from Member m where  m.email = :email and m.platform = :platform")
//    Optional<Member> findByEmail(@Param("email") String email,@Param("platform") Platform platform);
    Optional<Member> findByEmailAndPlatform(String email, Platform platform);

    Boolean existsByEmailAndPlatform(String email, Platform platform);

    @EntityGraph(attributePaths = {"roleSet"}, type = EntityGraph.EntityGraphType.LOAD)
    Optional<Member> findById(Long id);
}
