package yeonjeans.saera.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import yeonjeans.saera.domain.entity.member.Member;

@Builder
@AllArgsConstructor
@Getter
public class MemberInfoResponseDto {
    private String name;
    private String email;
    private String profileUrl;
    private int xp;

    public MemberInfoResponseDto(Member member) {
        this.email = member.getEmail();
        this.name = member.getName();
        this.profileUrl = member.getProfileUrl();;
        this.xp = member.getXp();
    };
}
