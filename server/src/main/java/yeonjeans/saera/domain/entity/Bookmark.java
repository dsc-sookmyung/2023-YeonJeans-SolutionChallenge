package yeonjeans.saera.domain.entity;

import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;
import yeonjeans.saera.domain.entity.example.ReferenceType;
import yeonjeans.saera.domain.entity.member.Member;

import javax.persistence.*;
import java.time.LocalDateTime;

@EntityListeners(AuditingEntityListener.class)
@NoArgsConstructor
@Getter
@Entity
public class Bookmark{

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    private Member member;

    private ReferenceType type;

    private Long fk;

    @CreatedDate
    private LocalDateTime createdDate;

    @Builder
    public Bookmark(Member member, ReferenceType type, Long fk) {
        this.member = member;
        this.type = type;
        this.fk = fk;
    }
}
