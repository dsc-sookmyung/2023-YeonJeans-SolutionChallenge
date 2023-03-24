package yeonjeans.saera.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;
import yeonjeans.saera.Service.WordServiceImpl;
import yeonjeans.saera.dto.ListItemDto;
import yeonjeans.saera.dto.WordListItemDto;
import yeonjeans.saera.dto.WordResponseDto;
import yeonjeans.saera.exception.ErrorResponse;
import yeonjeans.saera.security.dto.AuthMember;

import java.util.ArrayList;
import java.util.List;

@RequiredArgsConstructor
@RestController
public class WordController {
    private final WordServiceImpl wordService;

    @Operation(summary = "단어(발음 학습) 세부 조회", description = "word_id를 이용하여 word 레코드를 단건 조회합니다.", tags = { "Word Controller" },
            responses = {
                    @ApiResponse(responseCode = "200", description = "조회 성공", content = @Content(schema = @Schema(implementation = WordResponseDto.class))),
                    @ApiResponse(responseCode = "404", description = "존재하지 않는 리소스 접근", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
                    @ApiResponse(responseCode = "401", description = "인증 실패", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
                    @ApiResponse(responseCode = "499", description = "토큰 만료로 인한 인증 실패", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
            })
    @GetMapping("/words/{id}")
    public ResponseEntity<WordResponseDto> returnWord(@PathVariable Long id, @RequestHeader String Authorization){
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        AuthMember principal = (AuthMember) authentication.getPrincipal();

        WordResponseDto dto = wordService.getWord(id, principal.getId());
        return ResponseEntity.ok().body(dto);
    }

    @Operation(summary = "태그 별 단어 id list", description = "단어 tag_id를 통해 단어 id list 제공합니다.", tags = { "Word Controller" },
            responses = {
                    @ApiResponse(responseCode = "200", description = "조회 성공", content = { @Content(array = @ArraySchema(schema = @Schema(implementation = Long.class)))}),
                    @ApiResponse(responseCode = "404", description = "존재하지 않는 리소스 접근", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
                    @ApiResponse(responseCode = "401", description = "인증 실패", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
                    @ApiResponse(responseCode = "499", description = "토큰 만료로 인한 인증 실패", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
            })
    @GetMapping("/word-id")
    public ResponseEntity<?> returnWordIdList(@RequestParam(value = "tag_id", required = true) Long id) {
        List<Long> list = wordService.getWordIdList(id);
        return ResponseEntity.ok().body(list);
    }

    @Operation(summary = "단어 예시 음성 조회", description = "word_id를 이용하여 예시 음성을 조회 합니다.", tags = { "Word Controller"},
            responses = {
                    @ApiResponse(responseCode = "200", description = "조회 성공"),
                    @ApiResponse(responseCode = "404", description = "존재하지 않는 리소스 접근", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
            })
    @GetMapping("/words/record/{id}")
    public ResponseEntity<?> returnExampleRecord(@PathVariable Long id){
        Resource resource = wordService.getRecord(id);

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(new MediaType("audio", "wav"));

        return ResponseEntity.ok().headers(headers).body(resource);
    }

    @Operation(summary = "단어 리스트 조회", description = "단어 리스트 조회", tags = { "Word Controller" },
            responses = {
                    @ApiResponse(responseCode = "200", description = "조회 성공", content = { @Content(array = @ArraySchema(schema = @Schema(implementation = ListItemDto.class)))}),
                    @ApiResponse(responseCode = "401", description = "인증 실패", content = @Content(schema = @Schema(implementation = ErrorResponse.class))),
                    @ApiResponse(responseCode = "499", description = "토큰 만료로 인한 인증 실패", content = @Content(schema = @Schema(implementation = ErrorResponse.class)))
            }
    )
    @GetMapping("/words")
    public ResponseEntity<?> returnStatementList(
            @RequestParam(value = "bookmarked", defaultValue = "false") boolean bookmarked,
            @RequestHeader String Authorization
    ){
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        AuthMember principal = (AuthMember) authentication.getPrincipal();

        List<WordListItemDto> list = wordService.getWordList(bookmarked, principal.getId());

        return ResponseEntity.ok().body(list);
    }
}