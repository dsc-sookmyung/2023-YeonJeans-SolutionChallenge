package yeonjeans.saera.Service;

import org.springframework.core.io.Resource;
import yeonjeans.saera.dto.NameIdDto;
import yeonjeans.saera.dto.ListItemDto;
import yeonjeans.saera.dto.StatementResponseDto;

import java.util.ArrayList;
import java.util.List;

public interface StatementService {

    StatementResponseDto getStatement(Long id, Long memberId);

    List<ListItemDto> getStatements(String content, ArrayList<String> tags, Long memberId);

    List<ListItemDto> getPracticedStatements(Long memberId);

    List<ListItemDto> getBookmarkedStatements(Long memberId);

    Resource getTTS(Long id);

    List<NameIdDto> getTop5Statements();
}
