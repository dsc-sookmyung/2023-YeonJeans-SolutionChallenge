package yeonjeans.saera.dto;

import lombok.Getter;
import yeonjeans.saera.domain.entity.Bookmark;
import yeonjeans.saera.domain.entity.Practice;
import yeonjeans.saera.domain.entity.example.Word;

@Getter
public class WordResponseDto {
    private Long id;
    private String notation;
    private String pronunciation;
    private String definition;
    private Long tag_id;

    private Boolean bookmarked;
    private Boolean practiced;

    public WordResponseDto(Word word, Bookmark bookmark, Practice practice) {
        this.id = word.getId();
        this.notation = word.getNotation();
        this.pronunciation = word.getPronunciation();
        this.definition = word.getDefinition();
        this.tag_id = word.getTag().getId();

        this.bookmarked = bookmark != null;
        this.practiced = practice != null;
    }
}
