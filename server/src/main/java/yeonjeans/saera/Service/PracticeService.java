package yeonjeans.saera.Service;

import org.springframework.core.io.Resource;
import org.springframework.transaction.annotation.Transactional;
import yeonjeans.saera.domain.entity.Practice;
import yeonjeans.saera.domain.entity.example.ReferenceType;
import yeonjeans.saera.dto.PracticeRequestDto;
import yeonjeans.saera.dto.PracticeResponseDto;

public interface PracticeService {

    @Transactional
    public Practice create(PracticeRequestDto dto, Long memberId);

    public PracticeResponseDto read(ReferenceType type, Long fk, Long memberId);

    public Resource getRecord(ReferenceType type, Long fk, Long memberId);
}
