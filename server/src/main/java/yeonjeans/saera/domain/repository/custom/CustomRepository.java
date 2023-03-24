package yeonjeans.saera.domain.repository.custom;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import yeonjeans.saera.domain.entity.custom.Custom;
import yeonjeans.saera.domain.entity.member.Member;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

public interface CustomRepository extends JpaRepository<Custom, Long> {
    @Query("SELECT c, b, p " +
            "FROM Custom c " +
            "LEFT JOIN Bookmark b ON c.id = b.fk AND b.type = 2 AND b.member = :member " +
            "LEFT JOIN Practice p ON c.id = p.fk AND p.type = 2 AND p.member = :member " +
            "WHERE c.id = :customId")
    List<Object[]> findByIdWithBookmarkAndPractice(@Param("member") Member member, @Param("customId")Long customId);

    @Query("SELECT c, b, p " +
            "FROM Custom c " +
            "LEFT JOIN Bookmark b ON c.id = b.fk AND b.type = 2 AND b.member = :member " +
            "LEFT JOIN Practice p ON c.id = p.fk AND p.type = 2 AND p.member = :member " +
            "WHERE c.member = :member")
    List<Object[]> findAllWithBookmarkAndPractice(@Param("member") Member member);

    @Query("SELECT c, b, p " +
            "FROM Custom c " +
            "JOIN Bookmark b ON c.id = b.fk AND b.type = 2 AND b.member = :member " +
            "LEFT JOIN Practice p ON c.id = p.fk AND p.type = 2 AND p.member = :member ")
    List<Object[]> findBookmarkedAllAndPractice(@Param("member") Member member);

    @Query("SELECT c, b, p " +
            "FROM Custom c " +
            "LEFT JOIN Bookmark b ON c.id = b.fk AND b.type = 2 AND b.member = :member " +
            "LEFT JOIN Practice p ON c.id = p.fk AND p.type = 2 AND p.member = :member " +
            "WHERE c.content LIKE :content AND c.member = :member")
    List<Object[]> findAllByContentContaining(@Param("member")Member member, @Param("content") String content);

    @Query("SELECT c, b, p " +
            "FROM Custom c " +
            "LEFT JOIN Bookmark b ON c.id = b.fk AND b.type = 2 AND b.member = :member " +
            "LEFT JOIN Practice p ON c.id = p.fk AND p.type = 2 AND p.member = :member " +
            "WHERE c.id IN :idList AND c.member = :member")
    List<Object[]> findAllByIdWithBookmarkAndPractice(@Param("member")Member member, @Param("idList")List<Long> idList);


    @Query("SELECT c.id " +
            "FROM Custom c " +
            "JOIN CustomCtag ct ON c.id = ct.custom.id AND ct.tag.id IN "+
            "(SELECT t.id FROM CTag t WHERE t.name IN :tagnameList)")
    List<Long> findAllByTagnameIn(@Param("tagnameList") ArrayList<String> tagnameList);
}