package yeonjeans.saera.domain.repository;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.junit.jupiter.SpringExtension;
import org.springframework.transaction.annotation.Transactional;
import yeonjeans.saera.domain.entity.example.Tag;
import yeonjeans.saera.domain.repository.example.TagRepository;

import java.util.ArrayList;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

@ExtendWith(SpringExtension.class)
@SpringBootTest
@Transactional
public class TagRepositoryTest {

    @Autowired
    TagRepository tagRepository;

    @Transactional
    @Test
    public void findAllByNameIn() {
        //given
        String name1 = "test1";
        String name2 = "test2";

        tagRepository.save(new Tag(name1));
        tagRepository.save(new Tag(name2));

        String[] tagnameArray = {"test2", "test3"};
        ArrayList<String> tagnameList = new ArrayList<String>(List.of(tagnameArray));

        //when
        List<Tag> list = tagRepository.findAllByNameIn(tagnameList);
        //then
        for (Tag tag : list){
            System.out.println(tag.getName());
        }
    }
}
