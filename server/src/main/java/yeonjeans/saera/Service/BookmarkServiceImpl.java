package yeonjeans.saera.Service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import yeonjeans.saera.domain.entity.Bookmark;
import yeonjeans.saera.domain.entity.custom.Custom;
import yeonjeans.saera.domain.entity.example.ReferenceType;
import yeonjeans.saera.domain.entity.example.Word;
import yeonjeans.saera.domain.repository.BookmarkRepository;
import yeonjeans.saera.domain.entity.member.Member;
import yeonjeans.saera.domain.repository.custom.CustomRepository;
import yeonjeans.saera.domain.repository.example.WordRepository;
import yeonjeans.saera.domain.repository.member.MemberRepository;
import yeonjeans.saera.domain.entity.example.Statement;
import yeonjeans.saera.domain.repository.example.StatementRepository;
import yeonjeans.saera.exception.CustomException;

import static yeonjeans.saera.exception.ErrorCode.*;

@RequiredArgsConstructor
@Service
public class BookmarkServiceImpl {
    private final BookmarkRepository bookmarkRepository;
    private final MemberRepository memberRepository;
    private final StatementRepository statementRepository;
    private final WordRepository wordRepository;
    private final CustomRepository customRepository;

    @Transactional
    public boolean create(ReferenceType type, Long fk, Long memberId){
        Member member = memberRepository.findById(memberId).orElseThrow(()->new CustomException(MEMBER_NOT_FOUND));

        if(bookmarkRepository.existsByMemberAndTypeAndFk(member, type, fk)){
            throw new CustomException(ALREADY_BOOKMARKED);
        }

        switch (type){
            case STATEMENT :
                Statement state = statementRepository.findById(fk)
                        .orElseThrow(()->new CustomException(STATEMENT_NOT_FOUND));
                break;
            case WORD:
                Word word = wordRepository.findById(fk)
                        .orElseThrow(()->new CustomException(WORD_NOT_FOUND));
                break;
            case CUSTOM:
                Custom custom = customRepository.findById(fk)
                        .orElseThrow(()->new CustomException(CUSTOM_NOT_FOUND));
                break;
        }

        Bookmark bookmark = bookmarkRepository.save(Bookmark.builder()
                        .member(member)
                        .type(type)
                        .fk(fk)
                        .build());

        return bookmark != null;
    }

    @Transactional
    public void delete(ReferenceType type, Long fk, Long memberId){
        Member member = memberRepository.findById(memberId).orElseThrow(()->new CustomException(MEMBER_NOT_FOUND));

        Bookmark bookmark = bookmarkRepository.findByMemberAndTypeAndFk(member, type, fk).orElseThrow(()->new CustomException(BOOKMARK_NOT_FOUND));

        bookmarkRepository.delete(bookmark);
    }
}