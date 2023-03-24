package yeonjeans.saera.domain.entity.example;

import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import javax.persistence.*;
import java.util.List;

@NoArgsConstructor
@Getter
@Entity
public class Statement {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String content;

    @Column(columnDefinition = "MEDIUMBLOB")
    private byte[] file;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String pitchX;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String pitchY;

    @OneToMany(mappedBy = "statement")
    private List<StatementTag> tags;

    @Builder
    public Statement(String content, String pitchX, String pitchY, byte[] file) {
        this.content = content;
        this.pitchX = pitchX;
        this.pitchY = pitchY;
        this.file = file;
    }
}
