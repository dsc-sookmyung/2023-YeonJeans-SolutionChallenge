package yeonjeans.saera.Service;

import org.springframework.transaction.annotation.Transactional;
import yeonjeans.saera.domain.entity.member.Member;
import yeonjeans.saera.dto.MemberInfoResponseDto;
import yeonjeans.saera.dto.PracticeDaysResponseDto;
import yeonjeans.saera.dto.TokenResponseDto;

public interface MemberService {

    @Transactional
    TokenResponseDto join(Member request);

    TokenResponseDto login(Member request);

    @Transactional
    TokenResponseDto reIssueToken(String refreshToken);

   MemberInfoResponseDto getMemberInfo(Long memberId);

    MemberInfoResponseDto updateMember(Long id, String name);

    PracticeDaysResponseDto getPracticeDays(Long id);
}
