package yeonjeans.saera.domain.repository;

import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import yeonjeans.saera.domain.entity.Bookmark;
import yeonjeans.saera.domain.entity.Practice;
import yeonjeans.saera.domain.entity.custom.Custom;
import yeonjeans.saera.domain.entity.member.Member;
import yeonjeans.saera.domain.repository.custom.CustomRepository;
import yeonjeans.saera.domain.repository.member.MemberRepository;

import java.util.List;

@SpringBootTest
public class CustomRepositoryTest {
    @Autowired
    private MemberRepository memberRepository;
    @Autowired
    private CustomRepository customRepository;

    @Test
    public void getCustomList(){
        Member member = memberRepository.findById(1L).get();

        //List<Object[]> list = customRepository.findAllWithBookmarkAndPractice(member);
        List<Object[]> list = customRepository.findAllByContentContaining(member, "%다람쥐%");
        //when
        System.out.println(list.size());
        for(Object[] objects : list){
            printObject(objects);
        }
    }

    private void printObject(Object[] objects) {
        System.out.println(objects.length);

        Custom c = objects[0] instanceof Custom ? ((Custom) objects[0]) : null;
        Bookmark b = objects[1] instanceof Bookmark ? ((Bookmark) objects[1]) : null;
        Practice p = objects[2] instanceof Practice ? ((Practice) objects[2]) : null;

        System.out.println("========================================================");
        if(c != null) System.out.println("c.getContent(): " + c.getContent());
        if(b != null) System.out.println("b.getId(): " + b.getId());
        if(p != null) System.out.println("p.getModifiedDate(): " + p.getModifiedDate());
    }
}
