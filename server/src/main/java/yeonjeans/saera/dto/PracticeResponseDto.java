package yeonjeans.saera.dto;

import lombok.Data;
import yeonjeans.saera.domain.entity.Practice;
import yeonjeans.saera.util.Parsing;

import java.time.LocalDateTime;
import java.util.List;

@Data
public class PracticeResponseDto {
    LocalDateTime date;
    Double score;
    private List<Integer> pitch_x;
    private List<Double> pitch_y;
    private Integer pitch_length;

    public PracticeResponseDto(Practice practice) {
        this.date = practice.getModifiedDate()!=null? practice.getModifiedDate() : practice.getCreatedDate();
        this.score = practice.getScore();
        this.pitch_x = practice.getPitchX()!=null ? Parsing.stringToIntegerArray(practice.getPitchX()): null;
        this.pitch_y = practice.getPitchY()!=null ? Parsing.stringToDoubleArray(practice.getPitchY()): null;
        this.pitch_length = practice.getPitchLength();
    }
}