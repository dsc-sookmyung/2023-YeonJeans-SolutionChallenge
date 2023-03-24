package yeonjeans.saera.Service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import yeonjeans.saera.domain.entity.example.ReferenceType;
import yeonjeans.saera.domain.entity.member.Member;
import yeonjeans.saera.domain.repository.example.StatementRepository;
import yeonjeans.saera.domain.repository.example.WordRepository;
import yeonjeans.saera.domain.repository.member.MemberRepository;
import yeonjeans.saera.dto.ListItemDto;
import yeonjeans.saera.dto.WordListItemDto;
import yeonjeans.saera.exception.CustomException;
import yeonjeans.saera.exception.ErrorCode;

import java.time.LocalDate;
import java.util.*;
import java.util.stream.Collectors;

import static yeonjeans.saera.util.XPConstant.*;
import static yeonjeans.saera.domain.entity.example.ReferenceType.*;

@RequiredArgsConstructor
@Service
public class StudyServiceImpl {
    private final MemberRepository memberRepository;
    private final StatementRepository statementRepository;
    private final WordRepository wordRepository;

    private long dateSeed;
    Set<Long> wordSet = new HashSet<>();
    Set<Long> statementSet = new HashSet<>();

    @Transactional
    public List<Object> completeStudy(ReferenceType type, ArrayList<Long> idList, boolean isTodayStudy, Long memberId){
        Member member = memberRepository.findById(memberId).orElseThrow(()->new CustomException(ErrorCode.MEMBER_NOT_FOUND));

        if(isTodayStudy){
            int xp = type == STATEMENT ? XP_TODAY_STATEMENT : XP_TODAY_WORD;
            member.addXp(xp);
            memberRepository.save(member);

            idList = this.getIdList(type);
        }
        switch (type){
            case STATEMENT:
                return statementRepository.findAllByIdWithBookmarkAndPractice(member, idList)
                        .stream()
                        .map(ListItemDto::new)
                        .collect(Collectors.toList());
            case WORD:
                return wordRepository.findAllByIdWithBookmarkAndPractice(member, idList)
                        .stream()
                        .map(WordListItemDto::new)
                        .collect(Collectors.toList());
        }
        return null;
    }

    public synchronized ArrayList<Long> getIdList(ReferenceType type){
        LocalDate currentDate = LocalDate.now();
        long seed = currentDate.toEpochDay();

        if(seed != this.dateSeed) {
            Random random = new Random(seed);

            Set<Long> todayWordSet = new HashSet<>();
            Set<Long> todayStatementSet = new HashSet<>();

            while (todayWordSet.size() < 5) {
                int randomNumber = random.nextInt(39) + 1;
                if(!wordSet.contains((long) randomNumber))
                    todayWordSet.add((long) randomNumber);
            }

            while (todayStatementSet.size() < 5) {
                int randomNumber = random.nextInt(167) + 1;
                if(!statementSet.contains((long) randomNumber))
                    todayStatementSet.add((long) randomNumber);
            }

            this.statementSet = todayStatementSet;
            this.wordSet = todayWordSet;
            this.dateSeed = seed;
        }
        return type == STATEMENT ? new ArrayList<>(this.statementSet) : new ArrayList<>(this.wordSet);
   }
}