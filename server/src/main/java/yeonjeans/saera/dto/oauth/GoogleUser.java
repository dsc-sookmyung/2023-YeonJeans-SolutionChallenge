package yeonjeans.saera.dto.oauth;

import lombok.*;
import yeonjeans.saera.domain.entity.member.Member;
import yeonjeans.saera.domain.entity.member.MemberRole;
import yeonjeans.saera.domain.entity.member.Platform;

//구글(서드파티)로 액세스 토큰을 보내 받아올 구글에 등록된 사용자 정보
@ToString
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
public class GoogleUser {
    private String id;
    private String email;
    private Boolean verifiedEmail;
    private String name;
    private String givenName;
    private String familyName;
    private String picture;
    private String locale;

    public Member toMember(){
        Member member = Member.builder()
                .profileUrl(picture)
                .platform(Platform.GOOGLE)
                .email(email)
                .name(name)
                .build();
        member.addMemberRole(MemberRole.USER);
        return member;
    }
}