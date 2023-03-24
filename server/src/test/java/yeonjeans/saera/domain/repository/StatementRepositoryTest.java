package yeonjeans.saera.domain.repository;

import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.transaction.annotation.Transactional;
import yeonjeans.saera.domain.entity.Bookmark;
import yeonjeans.saera.domain.entity.Practice;
import yeonjeans.saera.domain.entity.example.Statement;
import yeonjeans.saera.domain.entity.member.Member;
import yeonjeans.saera.domain.repository.example.StatementRepository;
import yeonjeans.saera.domain.repository.member.MemberRepository;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest
@Transactional
public class StatementRepositoryTest {

    @Autowired
    StatementRepository statementRepository;
    @Autowired
    MemberRepository memberRepository;

    @Transactional
    @Test
    public void saveStatement(){
        //given
        String content = "content";
        String recordImg = "record";

        Statement result = statementRepository.save(Statement.builder().content(content).pitchX(recordImg).pitchY(recordImg).build());
        //when
        Optional<Statement> state = statementRepository.findById(result.getId());

        //then
        assertThat(state.isPresent());
    }

    @Test
    public void getStatementListItem(){
        //given
        Long memberId = 1L;
        Member member = memberRepository.findById(memberId).get();
        List<Object[]> list = statementRepository.findByIdWithBookmarkAndPractice(member, 9L);

        //when
        System.out.println(list.size());
        Object[] objects = list.get(0);

        System.out.println(objects.length);
        System.out.println(objects[1] == null);
        System.out.println(objects[2] == null);

        Statement s = objects[0] instanceof Statement ? ((Statement) objects[0]) : null;
        Bookmark b = objects[1] instanceof Bookmark ? ((Bookmark) objects[1]) : null;
        Practice p = objects[2] instanceof Practice ? ((Practice) objects[2]) : null;

        System.out.println("========================================================");
        System.out.println("s.getContent(): " + s.getContent());
//        System.out.println("b.getId(): " + b.getId());
//        System.out.println("p.getModifiedDate(): " + p.getModifiedDate());
        System.out.println("========================================================");
        //then
        Assertions.assertNotNull(s);
    }

    @Test
    public void findContaingContent(){
        Long memberId = 1L;
        Member member = memberRepository.findById(memberId).get();

        List<Object[]> list = statementRepository.findAllByContentContaining(member,"%안%");

        System.out.println("========================================================");
        System.out.println(list.size());
        Object[] objects = list.get(0);

        System.out.println(objects.length);
        System.out.println(objects[1] == null);
        System.out.println(objects[2] == null);

        Statement s = objects[0] instanceof Statement ? ((Statement) objects[0]) : null;
        Bookmark b = objects[1] instanceof Bookmark ? ((Bookmark) objects[1]) : null;
        Practice p = objects[2] instanceof Practice ? ((Practice) objects[2]) : null;

        System.out.println("s.getContent(): " + s.getContent());
        System.out.println("========================================================");
    }

    @Transactional
    @Test
    public void findByTag(){
        Long memberId = 1L;
        Member member = memberRepository.findById(memberId).get();

        String[] tagnameArray = {"일상", "존댓말"};
        ArrayList<String> tagnameList = new ArrayList<String>(List.of(tagnameArray));
        List<Long> list = statementRepository.findAllByTagnameIn(tagnameList);
        List<Object[]> result = statementRepository.findAllByIdWithBookmarkAndPractice(member, list);
        System.out.println("========================================================");
        System.out.println(list.size());
        for(Long id : list){
            System.out.println("@@@@ "+id);
        }
        System.out.println("========================================================");

        System.out.println(result.size());
        Object[] objects = result.get(0);

        System.out.println(objects.length);
        System.out.println(objects[1] == null);
        System.out.println(objects[2] == null);

        Statement s = objects[0] instanceof Statement ? ((Statement) objects[0]) : null;
        Bookmark b = objects[1] instanceof Bookmark ? ((Bookmark) objects[1]) : null;
        Practice p = objects[2] instanceof Practice ? ((Practice) objects[2]) : null;

        System.out.println("s.getContent(): " + s.getContent());
        System.out.println("========================================================");
    }
}
