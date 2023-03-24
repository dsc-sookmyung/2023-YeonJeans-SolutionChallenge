package yeonjeans.saera.dto;

import lombok.Data;
import yeonjeans.saera.domain.entity.Bookmark;
import yeonjeans.saera.domain.entity.Practice;
import yeonjeans.saera.domain.entity.custom.Custom;
import yeonjeans.saera.domain.entity.example.Statement;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Data
public class ListItemDto {
    private String content;
    private List<String> tags;
    private LocalDateTime date;

    private Long id;
    private Boolean practiced;
    private Boolean bookmarked;
    private Boolean recommended;

    public ListItemDto(Object[] result){
        Bookmark bookmark = result[1] instanceof Bookmark ? ((Bookmark) result[1]) : null;
        Practice practice = result[2] instanceof Practice ? ((Practice) result[2]) : null;
        this.practiced = practice != null;
        this.bookmarked = bookmark != null;
        this.recommended = false;

        this.date = practiced ? practice.getModifiedDate() : null;

        if(result[0] instanceof Statement){
            Statement statement = ((Statement) result[0]);

            this.id = statement.getId();
            this.content = statement.getContent();
            this.tags = statement.getTags().stream()
                    .map(statementTag -> statementTag.getTag().getName())
                    .collect(Collectors.toList());

        }else if(result[0] instanceof Custom){
            Custom custom = ((Custom) result[0]);

            this.id = custom.getId();
            this.content = custom.getContent();
            this.tags = custom.getTags().stream()
                    .map(customCtag -> customCtag.getTag().getName())
                    .collect(Collectors.toList());
        }
    }

    public ListItemDto(Object[] result, boolean recommended){
        Statement statement = result[0] instanceof Statement ? ((Statement) result[0]) : null;
        Bookmark bookmark = result[1] instanceof Bookmark ? ((Bookmark) result[1]) : null;
        Practice practice = result[2] instanceof Practice ? ((Practice) result[2]) : null;
        this.practiced = practice != null;
        this.bookmarked = bookmark != null;

        this.date = practiced ? practice.getModifiedDate() : null;

        this.id = statement.getId();
        this.content = statement.getContent();
        this.tags = statement.getTags().stream()
                .map(statementTag -> statementTag.getTag().getName())
                .collect(Collectors.toList());

        this.recommended = recommended;
    }
}
