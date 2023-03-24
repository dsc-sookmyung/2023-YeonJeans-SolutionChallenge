package yeonjeans.saera.dto.ML;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Setter
@AllArgsConstructor
@NoArgsConstructor
@Getter
public class ScoreResponseDto {
    double MAPE_score;
    double DTW_score;
}


