package yeonjeans.saera.Service;

import lombok.RequiredArgsConstructor;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.core.io.Resource;
import org.springframework.stereotype.Service;
import yeonjeans.saera.domain.entity.Bookmark;
import yeonjeans.saera.domain.entity.Practice;
import yeonjeans.saera.domain.entity.example.Word;
import yeonjeans.saera.domain.entity.member.Member;
import yeonjeans.saera.domain.repository.example.WordRepository;
import yeonjeans.saera.domain.repository.member.MemberRepository;
import yeonjeans.saera.dto.WordListItemDto;
import yeonjeans.saera.dto.WordResponseDto;
import yeonjeans.saera.exception.CustomException;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

import static yeonjeans.saera.exception.ErrorCode.*;

@Service
@RequiredArgsConstructor
public class WordServiceImpl {
    private final MemberRepository memberRepository;
    private final WordRepository wordRepository;

    public WordResponseDto getWord(Long id, Long memberId){
        Member member = memberRepository.findById(memberId).orElseThrow(()->new CustomException(MEMBER_NOT_FOUND));

        List<Object[]> list = wordRepository.findByIdWithBookmarkAndPractice(member, id);
        if(list.isEmpty()) throw new CustomException(WORD_NOT_FOUND);
        Object[] result = list.get(0);

        Word word = result[0] instanceof Word ? ((Word) result[0]) : null;
        Bookmark bookmark = result[1] instanceof Bookmark ? ((Bookmark) result[1]) : null;
        Practice practice = result[2] instanceof Practice ? ((Practice) result[2]) : null;

        return new WordResponseDto(word, bookmark, practice);
    }

    public List<Long> getWordIdList(Long tagId) {
        List<Long> mainWordTagList = new ArrayList<>(Arrays.asList(10L, 11L, 12L, 13L, 16L));
        List<Word> wordList;

        if(tagId == 0) wordList = wordRepository.findAllByTagIdNotIn(mainWordTagList);
        else wordList = wordRepository.findAllByTagId(tagId);

        if(wordList.isEmpty()) throw new CustomException(TAG_NOT_FOUND);

        List<Long> idList = wordList.stream().map(Word::getId).collect(Collectors.toList());
        Collections.shuffle(idList);
        return idList;
    }

    public Resource getRecord(Long id){
        Word word = wordRepository.findById(id)
                .orElseThrow(()->new CustomException(WORD_NOT_FOUND));

        return new ByteArrayResource(word.getFile()) {
            @Override
            public String getFilename() {
                return "audio.wav";
            }
        };
    }

    public List<WordListItemDto> getWordList(boolean bookmarked, Long memberId){
        Member member = memberRepository.findById(memberId)
                .orElseThrow(()->new CustomException(MEMBER_NOT_FOUND));

        if(bookmarked){
            return wordRepository.findBookmarkedWordsByMember(member).stream()
                    .map(WordListItemDto::new).collect(Collectors.toList());
        }
        return wordRepository.findAllWithMember(member).stream()
                .map(WordListItemDto::new).collect(Collectors.toList());
    }
}