package yeonjeans.saera.domain.repository.member;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import yeonjeans.saera.domain.entity.member.Login;

import java.util.Optional;

@Repository
public interface LoginRepository extends JpaRepository<Login, Long> {

    public Optional<Login> findByMemberId(Long MemberId);

    public Optional<Login> findByRefreshToken(String refreshToken);
}
