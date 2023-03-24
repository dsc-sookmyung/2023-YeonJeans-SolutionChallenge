package yeonjeans.saera.domain.entity.custom;

import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import javax.persistence.*;

@NoArgsConstructor
@Getter
@Entity
public class CustomCtag {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    private Custom custom;

    @ManyToOne
    private CTag tag;

    @Builder
    public CustomCtag(Custom custom, CTag tag) {
        this.custom = custom;
        this.tag = tag;
    }
}
