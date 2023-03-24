package yeonjeans.saera.dto.ML;

import lombok.Builder;
import lombok.Getter;

import java.util.ArrayList;

@Getter
public class ScoreRequestDto {

    ArrayList<Integer> target_pitch_x;
    ArrayList<Double> target_pitch_y;
    ArrayList<Integer> user_pitch_x;
    ArrayList<Double> user_pitch_y;

    @Builder
    public ScoreRequestDto(ArrayList<Integer> target_pitch_x, ArrayList<Double> target_pitch_y, ArrayList<Integer> user_pitch_x, ArrayList<Double> user_pitch_y) {
        this.target_pitch_x = target_pitch_x;
        this.target_pitch_y = target_pitch_y;
        this.user_pitch_x = user_pitch_x;
        this.user_pitch_y = user_pitch_y;
    }
}
