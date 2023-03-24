package yeonjeans.saera.dto;

import lombok.Getter;
import yeonjeans.saera.domain.entity.Bookmark;
import yeonjeans.saera.domain.entity.Practice;
import yeonjeans.saera.domain.entity.example.Word;

import java.time.LocalDateTime;

@Getter
public class WordListItemDto {
    private String notation;
    private String pronunciation;
    private String tag;
    private LocalDateTime date;

    private Long id;
    private Boolean practiced;
    private Boolean bookmarked;

    public WordListItemDto(Object[] result){
        Word word = result[0] instanceof Word ? ((Word) result[0]) : null;
        Bookmark bookmark = result[1] instanceof Bookmark ? ((Bookmark) result[1]) : null;
        Practice practice = result[2] instanceof Practice ? ((Practice) result[2]) : null;

        this.notation = word.getNotation();
        this.pronunciation = word.getPronunciation();
        this.tag = word.getTag().getName();
        this.id = word.getId();
        this.practiced = practice != null;
        this.bookmarked = bookmark != null;

        this.date = practiced ? practice.getModifiedDate() : null;
    }
}
