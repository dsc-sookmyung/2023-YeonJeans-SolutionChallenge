package yeonjeans.saera.dto;

import lombok.Getter;
import yeonjeans.saera.domain.entity.Bookmark;
import yeonjeans.saera.domain.entity.Practice;
import yeonjeans.saera.domain.entity.custom.Custom;
import yeonjeans.saera.util.Parsing;

import java.util.List;
import java.util.stream.Collectors;

@Getter
public class CustomResponseDto {
    private Long id;
    private String content;
    private List<Integer> pitch_x;
    private List<Double> pitch_y;

    List<String> tags;
    private Boolean bookmarked;
    private Boolean practiced;

    public CustomResponseDto(Custom custom, Bookmark bookmark, Practice practice){
        this.id = custom.getId();
        this.content = custom.getContent();
        this.pitch_x = Parsing.stringToIntegerArray(custom.getPitchX());
        this.pitch_y = Parsing.stringToDoubleArray(custom.getPitchY());
        this.tags = custom.getTags().stream()
                .map(customCtag -> customCtag.getTag().getName())
                .collect(Collectors.toList());

        this.bookmarked = bookmark != null;
        this.practiced = practice != null;
    }

    public CustomResponseDto(Custom custom){
        this.id = custom.getId();
        this.content = custom.getContent();
        this.pitch_x = Parsing.stringToIntegerArray(custom.getPitchX());
        this.pitch_y = Parsing.stringToDoubleArray(custom.getPitchY());
//      this.tags = custom.getTags().stream()
//              .map(customCtag -> customCtag.getTag().getName())
//              .collect(Collectors.toList());
        bookmarked = false;
        practiced = false;
    }
}
