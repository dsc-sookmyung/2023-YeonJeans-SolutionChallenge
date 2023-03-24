package yeonjeans.saera.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import yeonjeans.saera.domain.entity.custom.CTag;

@AllArgsConstructor
@Getter
public class NameIdDto {
    private String name;
    private Long id;

    public NameIdDto(CTag cTag) {
        this.name = cTag.getName();
        this.id = cTag.getId();
    }
}
