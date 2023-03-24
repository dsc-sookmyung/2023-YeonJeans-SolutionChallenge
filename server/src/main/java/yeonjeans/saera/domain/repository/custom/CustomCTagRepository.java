package yeonjeans.saera.domain.repository.custom;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.security.core.parameters.P;
import yeonjeans.saera.domain.entity.custom.CTag;
import yeonjeans.saera.domain.entity.custom.Custom;
import yeonjeans.saera.domain.entity.custom.CustomCtag;
import yeonjeans.saera.domain.entity.example.Tag;
import yeonjeans.saera.domain.entity.member.Member;

import java.util.List;

public interface CustomCTagRepository extends JpaRepository<CustomCtag, Long> {

    public List<CustomCtag> findAllByCustom(Custom custom);
}
