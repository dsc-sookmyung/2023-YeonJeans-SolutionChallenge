package yeonjeans.saera.domain.entity;

import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import yeonjeans.saera.domain.entity.example.ReferenceType;
import yeonjeans.saera.domain.entity.member.Member;

import javax.persistence.*;

@NoArgsConstructor
@Getter
@Entity
public class Practice extends BaseTimeEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(columnDefinition = "MEDIUMBLOB")
    private byte[] file;

    @Column(columnDefinition = "TEXT")
    private String pitchX;

    @Column(columnDefinition = "TEXT")
    private String pitchY;

    private Integer pitchLength;

    private Double score;

    private Integer count;

    @ManyToOne(fetch = FetchType.LAZY)
    private Member member;

    @Column(nullable = false)
    private ReferenceType type;

    @Column(nullable = false)
    private Long fk;

    @Builder
    public Practice(Member member, byte[] file, String pitchX, String pitchY, Double score, ReferenceType type, Long fk) {
        this.member = member;
        this.file = file;
        this.pitchX = pitchX;
        this.pitchY = pitchY;
        this.score = score;
        this.type = type;
        this.fk = fk;
        this.count = 1;
    }

    public void setCount(Integer count) {
        this.count = count;
    }

    public void setFile(byte[] file) {
        this.file = file;
    }

    public void setPitchX(String pitchX) {
        this.pitchX = pitchX;
    }

    public void setPitchY(String pitchY) {
        this.pitchY = pitchY;
    }

    public void setPitchLength(Integer pitchLength) { this.pitchLength = pitchLength; }

    public void setScore(Double score) {
        this.score = score;
    }
}
