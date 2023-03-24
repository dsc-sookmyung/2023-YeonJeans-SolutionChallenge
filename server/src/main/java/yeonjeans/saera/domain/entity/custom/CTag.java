package yeonjeans.saera.domain.entity.custom;

import lombok.Getter;
import lombok.NoArgsConstructor;
import yeonjeans.saera.domain.entity.member.Member;

import javax.persistence.*;
import java.util.List;

@NoArgsConstructor
@Getter
@Entity
public class CTag {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String name;

    @ManyToOne
    private Member member;

    @OneToMany(mappedBy = "tag")
    private List<CustomCtag> customs;

    public CTag(String name, Member member) {
        this.name = name;
        this.member = member;
    }
}
