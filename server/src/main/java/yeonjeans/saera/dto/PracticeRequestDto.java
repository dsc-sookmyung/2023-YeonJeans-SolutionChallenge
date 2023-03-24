package yeonjeans.saera.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

import org.springframework.web.multipart.MultipartFile;
import yeonjeans.saera.domain.entity.example.ReferenceType;

@Getter
@AllArgsConstructor
public class PracticeRequestDto {
    private ReferenceType type;
    private Long fk;
    private MultipartFile record;
    private boolean isTodayStudy;
}
