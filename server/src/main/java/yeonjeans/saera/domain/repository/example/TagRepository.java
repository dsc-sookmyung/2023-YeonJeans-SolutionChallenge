package yeonjeans.saera.domain.repository.example;

import org.hibernate.annotations.Fetch;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import yeonjeans.saera.domain.entity.example.StatementTag;
import yeonjeans.saera.domain.entity.example.Tag;

import java.util.ArrayList;
import java.util.List;

public interface TagRepository extends JpaRepository<Tag, Long> {

    public Tag findByName(String tagname);

    public List<Tag> findAllByNameIn(ArrayList<String> tagnames);

    public List<StatementTag> findStatementsByNameIn(ArrayList<String> tagnames);
}
