package yeonjeans.saera.dto.ML;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.util.ArrayList;

@NoArgsConstructor
@AllArgsConstructor
@Getter
public class PitchGraphDto {
    ArrayList<Integer> pitch_x;
    ArrayList<Double> pitch_y;
    Integer pitch_length;

    public PitchGraphDto(ArrayList<Integer> pitch_x, ArrayList<Double> pitch_y){
        this.pitch_x = pitch_x;
        this.pitch_y = pitch_y;
        this.pitch_length = null;
    }
}
