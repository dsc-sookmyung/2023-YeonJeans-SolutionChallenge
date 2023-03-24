package yeonjeans.saera.domain.repository;

import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import yeonjeans.saera.domain.entity.Bookmark;
import yeonjeans.saera.domain.entity.Practice;
import yeonjeans.saera.domain.entity.example.Word;
import yeonjeans.saera.domain.entity.member.Member;
import yeonjeans.saera.domain.repository.example.WordRepository;
import yeonjeans.saera.domain.repository.member.MemberRepository;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

@SpringBootTest
public class WordRepositoryTest {
    @Autowired
    WordRepository wordRepository;
    @Autowired
    MemberRepository memberRepository;

    @Test
    public void getWordWithPracticeAndBookmark(){
        Long memberId = 1L;
        Member member = memberRepository.findById(memberId).get();
        List<Object[]> list = wordRepository.findByIdWithBookmarkAndPractice(member, 10L);

        //when
        System.out.println(list.size());
        Object[] objects = list.get(0);

        System.out.println(objects.length);
        System.out.println(objects[1] == null);
        System.out.println(objects[2] == null);

        Word w = objects[0] instanceof Word ? ((Word) objects[0]) : null;
        Bookmark b = objects[1] instanceof Bookmark ? ((Bookmark) objects[1]) : null;
        Practice p = objects[2] instanceof Practice ? ((Practice) objects[2]) : null;

        System.out.println("========================================================");
        System.out.println("w.getNotation(): " + w.getNotation());
//        System.out.println("b.getId(): " + b.getId());
//        System.out.println("p.getModifiedDate(): " + p.getModifiedDate());
        System.out.println("========================================================");

        Assertions.assertNotNull(w);
    }

    @Test
    public void getEtcWordIdList(){
        List<Long> mainWordTagList = new ArrayList<Long>(Arrays.asList(10L, 11L, 12L, 13L, 16L));
        List<Word> wordList;

        wordList = wordRepository.findAllByTagIdNotIn(mainWordTagList);

        Assertions.assertFalse(wordList.isEmpty());
    }
}
