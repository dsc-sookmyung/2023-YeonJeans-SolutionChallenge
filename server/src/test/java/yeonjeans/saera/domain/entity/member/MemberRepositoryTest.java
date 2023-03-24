package yeonjeans.saera.domain.entity.member;

import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.transaction.annotation.Transactional;
import yeonjeans.saera.domain.repository.member.MemberRepository;

@SpringBootTest
public class MemberRepositoryTest {
    @Autowired
    MemberRepository memberRepository;

    @Transactional
    @Test
    public void findMemberWithPlatformTest(){
        Member member = Member.builder()
                .profileUrl("test")
                .platform(Platform.GOOGLE)
                .email("test")
                .name("testuser1")
                .build();
        member.addMemberRole(MemberRole.USER);
        memberRepository.save(member);

        Member result = memberRepository.findByEmailAndPlatform("test", Platform.GOOGLE).get();

        Assertions.assertEquals(member, result);
    }

    @Transactional
    @Test
    public void existsByEmailAndPlatform(){
        Member member = Member.builder()
                .profileUrl("test")
                .platform(Platform.GOOGLE)
                .email("test")
                .name("testuser1")
                .build();
        member.addMemberRole(MemberRole.USER);
        memberRepository.save(member);

        Boolean result1 = memberRepository.existsByEmailAndPlatform("test", Platform.GOOGLE);
        Boolean result2 = memberRepository.existsByEmailAndPlatform("tes", Platform.GOOGLE);

        Assertions.assertEquals(true, result1);
        Assertions.assertEquals(false, result2);
    }
}
