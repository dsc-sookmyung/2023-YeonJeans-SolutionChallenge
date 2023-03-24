package yeonjeans.saera.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.util.ArrayList;

@Getter
@AllArgsConstructor
@NoArgsConstructor
public class CustomRequestDto {
    private String content;
    private ArrayList<String> tags;
}
