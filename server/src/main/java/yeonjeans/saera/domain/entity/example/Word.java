package yeonjeans.saera.domain.entity.example;

import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import javax.persistence.*;

@NoArgsConstructor
@Getter
@Entity
public class Word {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(columnDefinition = "MEDIUMBLOB")
    private byte[] file;

    @Column(nullable = false)
    private String notation;

    private String definition;

    private String pronunciation;

    @OneToOne(fetch = FetchType.LAZY)
    private Tag tag;

    @Builder
    public Word(byte[] file, String notation, String definition, String pronunciation, Tag tag) {
        this.notation = notation;
        this.definition = definition;
        this.pronunciation = pronunciation;
        this.file = file;
        this.tag = tag;
    }
}
