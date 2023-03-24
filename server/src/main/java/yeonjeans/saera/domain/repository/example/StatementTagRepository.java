package yeonjeans.saera.domain.repository.example;

import org.springframework.data.jpa.repository.JpaRepository;
import yeonjeans.saera.domain.entity.example.StatementTag;

import java.util.List;

public interface StatementTagRepository extends JpaRepository<StatementTag, Long> {
}
