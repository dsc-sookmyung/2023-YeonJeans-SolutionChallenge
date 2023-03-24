package yeonjeans.saera.dto;

import lombok.Getter;
import yeonjeans.saera.domain.entity.example.ReferenceType;

import java.util.ArrayList;

@Getter
public class CompleteStudyRequestDto {
    private ReferenceType type;
    private ArrayList<Long> fkList;
    private boolean isTodayStudy;
}
