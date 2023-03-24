package yeonjeans.saera.domain.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import yeonjeans.saera.domain.entity.Bookmark;
import yeonjeans.saera.domain.entity.example.ReferenceType;
import yeonjeans.saera.domain.entity.member.Member;
import yeonjeans.saera.domain.entity.example.Statement;

import java.util.List;
import java.util.Optional;

public interface BookmarkRepository extends JpaRepository<Bookmark, Long> {

    public List<Bookmark> findAllByMemberAndType(Member member, ReferenceType type);

    public Optional<Bookmark> findByMemberAndTypeAndFk(Member member, ReferenceType type, Long fk);

    public Boolean existsByMemberAndTypeAndFk(Member member, ReferenceType type, Long fk);
}
