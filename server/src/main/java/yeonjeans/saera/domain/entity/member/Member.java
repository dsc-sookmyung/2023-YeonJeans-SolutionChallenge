package yeonjeans.saera.domain.entity.member;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import yeonjeans.saera.domain.entity.BaseTimeEntity;

import javax.persistence.*;
import java.util.HashSet;
import java.util.Set;

@Getter
@Builder
@AllArgsConstructor
@NoArgsConstructor
@Entity
public class Member extends BaseTimeEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String email;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Platform platform;

    @ElementCollection(fetch = FetchType.LAZY)
    @Builder.Default
    private Set<MemberRole> roleSet = new HashSet<>();

    @Column
    private MemberStatus status;

    @Column(nullable = false)
    private String name;

    @Column
    private String profileUrl;

    @Column
    private int xp;

    @Column
    private int attendance_count;

    public void setNickname(String name) {
        this.name = name;
    }

    public void setProfile(String profileUrl) {
        this.profileUrl = profileUrl;
    }

    public void setAttendance_count(int count) {
        this.attendance_count = count;
    };

    public void addXp(int xp) {
        this.xp = this.xp + xp;
    }

    public void addMemberRole(MemberRole memberRole){
        roleSet.add(memberRole);
    }
}
