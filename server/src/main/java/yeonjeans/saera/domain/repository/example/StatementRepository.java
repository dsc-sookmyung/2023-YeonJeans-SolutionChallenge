package yeonjeans.saera.domain.repository.example;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.security.core.parameters.P;
import yeonjeans.saera.domain.entity.example.ReferenceType;
import yeonjeans.saera.domain.entity.example.Statement;
import yeonjeans.saera.domain.entity.example.StatementTag;
import yeonjeans.saera.domain.entity.member.Member;

import java.util.ArrayList;
import java.util.List;

public interface StatementRepository extends JpaRepository<Statement, Long> {

    @Query("SELECT s, b, p " +
            "FROM Statement s " +
            "LEFT JOIN Bookmark b ON s.id = b.fk AND b.type = 'STATEMENT' AND b.member = :member " +
            "LEFT JOIN Practice p ON s.id = p.fk AND p.type = 'STATEMENT' AND p.member = :member " +
            "WHERE s.id = :statementId")
    List<Object[]> findByIdWithBookmarkAndPractice(@Param("member")Member member, @Param("statementId")Long statementId);

    @Query("SELECT s, b, p " +
            "FROM Statement s " +
            "LEFT JOIN Bookmark b ON s.id = b.fk AND b.type = 'STATEMENT' AND b.member = :member " +
            "LEFT JOIN Practice p ON s.id = p.fk AND p.type = 'STATEMENT' AND p.member = :member")
    List<Object[]> findAllWithBookmarkAndPractice(@Param("member")Member member);

    @Query("SELECT s, b, p " +
            "FROM Statement s " +
            "LEFT JOIN Bookmark b ON s.id = b.fk AND b.type = 'STATEMENT' AND b.member = :member " +
            "LEFT JOIN Practice p ON s.id = p.fk AND p.type = 'STATEMENT' AND p.member = :member " +
            "WHERE s.id IN :idList ")
    List<Object[]> findAllByIdWithBookmarkAndPractice(@Param("member")Member member, @Param("idList")List<Long> idList);

    @Query("SELECT s, b, p " +
            "FROM Statement s " +
            "JOIN Practice p ON s.id = p.fk AND p.type = :type AND p.member = :member " +
            "LEFT JOIN Bookmark b ON s.id = b.fk AND b.type = :type AND b.member = :member " +
            "ORDER BY p.modifiedDate DESC ")
    List<Object[]> findPracticed(@Param("member")Member member, @Param("type")ReferenceType type);

    @Query("SELECT s, b, p " +
            "FROM Statement s " +
            "JOIN Bookmark b ON s.id = b.fk AND b.type = :type AND b.member = :member " +
            "LEFT JOIN Practice p ON s.id = p.fk AND p.type = :type AND p.member = :member")
    List<Object[]> findBookmarked(@Param("member")Member member, @Param("type")ReferenceType type);

    @Query("SELECT s, b, p " +
            "FROM Statement s " +
            "LEFT JOIN Bookmark b ON s.id = b.fk AND b.type = 'STATEMENT' AND b.member = :member " +
            "LEFT JOIN Practice p ON s.id = p.fk AND p.type = 'STATEMENT' AND p.member = :member " +
            "WHERE s.content LIKE :content")
    List<Object[]> findAllByContentContaining(@Param("member")Member member, @Param("content") String content);

    @Query("SELECT s.id " +
        "FROM Statement s " +
        "JOIN StatementTag st ON s.id = st.statement.id AND st.tag.id IN "+
        "(SELECT t.id FROM Tag t WHERE t.name IN :tagnameList)")
    List<Long> findAllByTagnameIn(@Param("tagnameList") ArrayList<String> tagnameList);

    @Query("SELECT s.id " +
            "FROM Statement s " +
            "JOIN StatementTag st ON s.id = st.statement.id AND st.tag.id IN "+
            "(SELECT t.id FROM Tag t WHERE t.name IN :tagnameList)" +
            "WHERE s.content LIKE :keyword")
    List<Long> findAllByTagnameInAndContentContaining(@Param("tagnameList") ArrayList<String> tagnameList, @Param("keyword") String keyword);
}
