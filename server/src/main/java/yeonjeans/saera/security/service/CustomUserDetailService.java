package yeonjeans.saera.security.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;
import yeonjeans.saera.domain.entity.member.Member;
import yeonjeans.saera.domain.repository.member.MemberRepository;
import yeonjeans.saera.exception.CustomException;
import yeonjeans.saera.security.dto.AuthMember;

import static yeonjeans.saera.exception.ErrorCode.*;

import java.util.stream.Collectors;

@Log4j2
@RequiredArgsConstructor
@Service
public class CustomUserDetailService implements UserDetailsService {

    private final MemberRepository memberRepository;

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        Long memberId = Long.parseLong(username);
        Member member = memberRepository.findById(memberId)
                .orElseThrow(()->new CustomException(MEMBER_NOT_FOUND));
        AuthMember authMember = new AuthMember(
                member.getEmail(),
                "",
                member.getRoleSet().stream()
                        .map(role->new SimpleGrantedAuthority("ROLE_"+role.name()))
                        .collect(Collectors.toSet()),
                member.getId(),
                member.getName()
        );
        return authMember;
    }
}
