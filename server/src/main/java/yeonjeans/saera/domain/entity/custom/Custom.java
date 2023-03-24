package yeonjeans.saera.domain.entity.custom;

import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;
import yeonjeans.saera.domain.entity.member.Member;

import javax.persistence.*;
import java.time.LocalDateTime;
import java.util.List;

@EntityListeners(AuditingEntityListener.class)
@NoArgsConstructor
@Getter
@Entity
public class Custom {

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

    @OneToMany(mappedBy = "custom")
    private List<CustomCtag> tags;

    @ManyToOne
    private Member member;

    @CreatedDate
    private LocalDateTime createdDate;

    @Builder
    public Custom(String content, String pitchX, String pitchY, byte[] file, Member member) {
        this.content = content;
        this.pitchX = pitchX;
        this.pitchY = pitchY;
        this.file = file;
        this.member = member;
    }
}
