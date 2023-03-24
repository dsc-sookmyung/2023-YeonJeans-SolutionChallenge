package yeonjeans.saera.domain.entity.example;

import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import javax.persistence.*;

@NoArgsConstructor
@Getter
@Entity
public class StatementTag {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    private Statement statement;

    @ManyToOne
    private Tag tag;

    @Builder
    public StatementTag(Statement statement, Tag tag) {
        this.statement = statement;
        this.tag = tag;
    }
}
