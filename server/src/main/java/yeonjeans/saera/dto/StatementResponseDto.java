package yeonjeans.saera.dto;

import lombok.Data;
import yeonjeans.saera.domain.entity.Bookmark;
import yeonjeans.saera.domain.entity.Practice;
import yeonjeans.saera.domain.entity.example.Statement;
import yeonjeans.saera.util.Parsing;

import java.util.List;
import java.util.stream.Collectors;

@Data
public class StatementResponseDto {
    private Long id;
    private String content;
    private List<Integer> pitch_x;
    private List<Double> pitch_y;

    List<String> tags;
    private Boolean bookmarked;
    private Boolean practiced;

    public StatementResponseDto(Statement state, Bookmark bookmark, Practice practice){
        this.id = state.getId();
        this.content = state.getContent();
        this.pitch_x = Parsing.stringToIntegerArray(state.getPitchX());
        this.pitch_y = Parsing.stringToDoubleArray(state.getPitchY());
        this.tags = state.getTags().stream()
                .map(statementTag -> statementTag.getTag().getName())
                .collect(Collectors.toList());

        this.bookmarked = bookmark != null;
        this.practiced = practice != null;
    }
}
